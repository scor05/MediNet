<?php

use App\Http\Middleware\SupabaseAuth;
use App\Models\Notification;
use App\Models\User;
use App\Models\Waitlist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

function communicationSecurityAuthenticate(User $user): void
{
    app()->instance(SupabaseAuth::class, new class($user)
    {
        public function __construct(private User $user) {}

        public function handle(Request $request, Closure $next)
        {
            $request->setUserResolver(fn () => $this->user);

            return $next($request);
        }
    });
}

function communicationSecurityFixture(): array
{
    $suffix = Str::lower(Str::random(12));
    $now = now();

    $createUser = function (string $name) use ($suffix, $now): int {
        return DB::table('users')->insertGetId([
            'name' => $name,
            'email' => Str::slug($name)."-{$suffix}@example.test",
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $patientA = $createUser('Waitlist Patient A');
    $patientB = $createUser('Waitlist Patient B');
    $doctorA = $createUser('Waitlist Doctor A');
    $doctorB = $createUser('Waitlist Doctor B');
    $secretaryA = $createUser('Waitlist Secretary A');
    $secretaryB = $createUser('Waitlist Secretary B');

    $clientA = DB::table('clients')->insertGetId([
        'nit' => "COMM-A-{$suffix}",
        'name' => 'Communication Organization A',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $clientB = DB::table('clients')->insertGetId([
        'nit' => "COMM-B-{$suffix}",
        'name' => 'Communication Organization B',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $createClinic = function (int $clientId, string $label) use ($suffix, $now): int {
        return DB::table('clinics')->insertGetId([
            'name' => "Communication Clinic {$label}",
            'address' => "Address {$label}",
            'phone' => "{$label}-{$suffix}",
            'email' => "clinic-{$label}-{$suffix}@example.test",
            'id_client' => $clientId,
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $clinicA = $createClinic($clientA, 'a');
    $clinicB = $createClinic($clientB, 'b');

    DB::table('client_users')->insert([
        [
            'id_client' => $clientA,
            'id_user' => $doctorA,
            'role' => 1,
            'is_admin' => false,
            'is_active' => true,
        ],
        [
            'id_client' => $clientB,
            'id_user' => $doctorB,
            'role' => 1,
            'is_admin' => false,
            'is_active' => true,
        ],
        [
            'id_client' => $clientA,
            'id_user' => $secretaryA,
            'role' => 2,
            'is_admin' => false,
            'is_active' => true,
        ],
        [
            'id_client' => $clientB,
            'id_user' => $secretaryB,
            'role' => 2,
            'is_admin' => false,
            'is_active' => true,
        ],
    ]);

    $createSchedule = function (int $doctorId, int $clinicId) use ($now): int {
        return DB::table('schedules')->insertGetId([
            'id_doctor' => $doctorId,
            'id_clinic' => $clinicId,
            'day_of_week' => 1,
            'start_time' => '08:00',
            'end_time' => '12:00',
            'duration' => 30,
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $scheduleA = $createSchedule($doctorA, $clinicA);
    $scheduleB = $createSchedule($doctorB, $clinicB);

    $createAppointment = function (
        int $scheduleId,
        int $patientId,
        string $time,
    ) use ($now): int {
        return DB::table('appointments')->insertGetId([
            'id_schedule' => $scheduleId,
            'id_patient' => $patientId,
            'name_patient' => 'Waitlist patient',
            'date' => '2026-11-02',
            'status' => 'accepted',
            'start_time' => $time,
            'created_by' => $patientId,
            'updated_by' => $patientId,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $appointmentA = $createAppointment($scheduleA, $patientB, '08:00');
    $appointmentB = $createAppointment($scheduleB, $patientA, '08:00');

    $waitlistA = DB::table('waitlists')->insertGetId([
        'id_patient' => $patientA,
        'id_target_appointment' => $appointmentA,
        'status' => 'waiting',
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $waitlistB = DB::table('waitlists')->insertGetId([
        'id_patient' => $patientB,
        'id_target_appointment' => $appointmentB,
        'status' => 'waiting',
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $notificationA = DB::table('notifications')->insertGetId([
        'id_user' => $patientA,
        'type' => 'reminder',
        'message' => 'Notification A',
        'sent_at' => $now,
        'channel' => 'email',
    ]);
    $notificationB = DB::table('notifications')->insertGetId([
        'id_user' => $patientB,
        'type' => 'reminder',
        'message' => 'Notification B',
        'sent_at' => $now,
        'channel' => 'email',
    ]);

    DB::table('notification_preferences')->insert([
        ['id_user' => $patientA, 'channel' => 'email'],
        ['id_user' => $patientB, 'channel' => 'sms'],
    ]);

    return compact(
        'patientA',
        'patientB',
        'doctorA',
        'doctorB',
        'secretaryA',
        'secretaryB',
        'waitlistA',
        'waitlistB',
        'notificationA',
        'notificationB',
    );
}

it('only returns waitlists visible to the authenticated actor', function (
    string $actorKey,
    string $visibleWaitlistKey,
) {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture[$actorKey]));

    $response = $this->withToken('valid-test-token')->getJson('/api/waitlists');

    $response->assertOk();
    expect(collect($response->json())->pluck('id')->all())
        ->toBe([$fixture[$visibleWaitlistKey]]);
})->with([
    'patient' => ['patientA', 'waitlistA'],
    'doctor' => ['doctorA', 'waitlistA'],
    'secretary' => ['secretaryA', 'waitlistA'],
]);

it('denies reading modifying and deleting a foreign waitlist id', function (
    string $actorKey,
) {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture[$actorKey]));
    $uri = '/api/waitlists/'.$fixture['waitlistA'];

    $this->withToken('valid-test-token')->getJson($uri)->assertForbidden();
    $this->withToken('valid-test-token')
        ->patchJson($uri, ['status' => 'notified'])
        ->assertForbidden();
    $this->withToken('valid-test-token')->deleteJson($uri)->assertForbidden();

    expect(Waitlist::find($fixture['waitlistA']))->not->toBeNull()
        ->and(Waitlist::findOrFail($fixture['waitlistA'])->status)->toBe('waiting');
})->with([
    'unrelated patient' => ['patientB'],
    'doctor from another organization' => ['doctorB'],
    'secretary from another organization' => ['secretaryB'],
]);

it('uses the authenticated patient for their waitlist collection', function () {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture['patientA']));

    $response = $this->withToken('valid-test-token')->getJson('/api/waitlists/mine');

    $response->assertOk();
    expect(collect($response->json())->pluck('id')->all())
        ->toBe([$fixture['waitlistA']]);

    $this->withToken('valid-test-token')
        ->getJson('/api/waitlists/patient/'.$fixture['patientB'])
        ->assertNotFound();
});

it('allows a patient to read and cancel but not hard delete their own waitlist', function () {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture['patientA']));
    $uri = '/api/waitlists/'.$fixture['waitlistA'];

    $this->withToken('valid-test-token')->getJson($uri)->assertOk();
    $this->withToken('valid-test-token')
        ->patchJson($uri, ['status' => 'cancelled'])
        ->assertOk();
    $this->withToken('valid-test-token')->deleteJson($uri)->assertForbidden();

    expect(Waitlist::findOrFail($fixture['waitlistA'])->status)
        ->toBe('cancelled');
});

it('only lists reads and deletes notifications owned by the actor', function () {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture['patientA']));

    $response = $this->withToken('valid-test-token')->getJson('/api/notifications');
    $response->assertOk();
    expect(collect($response->json())->pluck('id')->all())
        ->toBe([$fixture['notificationA']]);

    $foreignUri = '/api/notifications/'.$fixture['notificationB'];
    $this->withToken('valid-test-token')->getJson($foreignUri)->assertForbidden();
    $this->withToken('valid-test-token')->deleteJson($foreignUri)->assertForbidden();
    expect(Notification::find($fixture['notificationB']))->not->toBeNull();

    $this->withToken('valid-test-token')
        ->deleteJson('/api/notifications/'.$fixture['notificationA'])
        ->assertNoContent();
});

it('does not expose a public notification creation endpoint', function () {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture['patientA']));

    $this->withToken('valid-test-token')->postJson('/api/notifications', [
        'id_user' => $fixture['patientB'],
        'type' => 'reminder',
        'message' => 'Arbitrary message',
        'channel' => 'email',
    ])->assertMethodNotAllowed();

    expect(Notification::where('message', 'Arbitrary message')->exists())->toBeFalse();
});

it('reads updates and deletes only the authenticated users preferences', function () {
    $fixture = communicationSecurityFixture();
    communicationSecurityAuthenticate(User::findOrFail($fixture['patientA']));

    $response = $this->withToken('valid-test-token')
        ->getJson('/api/notification-preferences');
    $response->assertOk();
    expect(collect($response->json())->pluck('channel')->all())->toBe(['email']);

    $this->withToken('valid-test-token')
        ->putJson('/api/notification-preferences', [
            'id_user' => $fixture['patientB'],
            'channels' => ['push'],
        ])
        ->assertOk();

    expect(DB::table('notification_preferences')
        ->where('id_user', $fixture['patientA'])
        ->pluck('channel')->all())->toBe(['push'])
        ->and(DB::table('notification_preferences')
            ->where('id_user', $fixture['patientB'])
            ->pluck('channel')->all())->toBe(['sms']);

    $this->withToken('valid-test-token')
        ->deleteJson('/api/notification-preferences')
        ->assertNoContent();

    expect(DB::table('notification_preferences')
        ->where('id_user', $fixture['patientA'])->exists())->toBeFalse()
        ->and(DB::table('notification_preferences')
            ->where('id_user', $fixture['patientB'])->exists())->toBeTrue();

    $this->withToken('valid-test-token')
        ->getJson('/api/notification-preferences/'.$fixture['patientB'])
        ->assertNotFound();
});
