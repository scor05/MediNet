<?php

use App\Http\Middleware\SupabaseAuth;
use App\Models\Appointment;
use App\Models\User;
use App\Services\AppointmentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Mockery\MockInterface;

function appointmentSecurityAuthenticate(User $user): void
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

function appointmentSecurityFixture(): array
{
    $suffix = Str::lower(Str::random(12));
    $now = now();

    $user = function (string $name) use ($suffix, $now): int {
        return DB::table('users')->insertGetId([
            'name' => $name,
            'email' => Str::slug($name)."-{$suffix}@example.test",
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $patientA = $user('Paciente A');
    $patientB = $user('Paciente B');
    $doctorA = $user('Doctor A');
    $doctorB = $user('Doctor B');
    $secretaryA = $user('Secretaria A');
    $secretaryB = $user('Secretaria B');

    $clientA = DB::table('clients')->insertGetId([
        'nit' => "AUTH-A-{$suffix}",
        'name' => 'Organización A',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $clientB = DB::table('clients')->insertGetId([
        'nit' => "AUTH-B-{$suffix}",
        'name' => 'Organización B',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $clinicA = DB::table('clinics')->insertGetId([
        'name' => 'Clínica A',
        'address' => 'Dirección A',
        'phone' => "A-{$suffix}",
        'email' => "clinic-a-{$suffix}@example.test",
        'id_client' => $clientA,
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $clinicB = DB::table('clinics')->insertGetId([
        'name' => 'Clínica B',
        'address' => 'Dirección B',
        'phone' => "B-{$suffix}",
        'email' => "clinic-b-{$suffix}@example.test",
        'id_client' => $clientB,
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

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

    $scheduleA = DB::table('schedules')->insertGetId([
        'id_doctor' => $doctorA,
        'id_clinic' => $clinicA,
        'day_of_week' => 1,
        'start_time' => '08:00',
        'end_time' => '12:00',
        'is_active' => true,
        'duration' => 30,
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $scheduleB = DB::table('schedules')->insertGetId([
        'id_doctor' => $doctorB,
        'id_clinic' => $clinicB,
        'day_of_week' => 1,
        'start_time' => '08:00',
        'end_time' => '12:00',
        'is_active' => true,
        'duration' => 30,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $appointment = function (
        int $scheduleId,
        int $patientId,
        string $patientName,
        string $startTime,
    ) use ($now): int {
        return DB::table('appointments')->insertGetId([
            'id_schedule' => $scheduleId,
            'id_patient' => $patientId,
            'name_patient' => $patientName,
            'date' => '2026-11-02',
            'status' => 'accepted',
            'start_time' => $startTime,
            'created_by' => $patientId,
            'updated_by' => $patientId,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $appointmentA = $appointment($scheduleA, $patientA, 'Paciente A', '08:00');
    $appointmentAOtherPatient = $appointment(
        $scheduleA,
        $patientB,
        'Paciente B',
        '08:30',
    );
    $appointmentB = $appointment($scheduleB, $patientB, 'Paciente B', '08:00');

    return compact(
        'patientA',
        'patientB',
        'doctorA',
        'doctorB',
        'secretaryA',
        'secretaryB',
        'scheduleA',
        'scheduleB',
        'appointmentA',
        'appointmentAOtherPatient',
        'appointmentB',
    );
}

it('filters the general appointment list for patients doctors and secretaries', function (
    string $actorKey,
    array $visibleAppointmentKeys,
) {
    $fixture = appointmentSecurityFixture();
    appointmentSecurityAuthenticate(User::findOrFail($fixture[$actorKey]));

    $response = $this->withToken('valid-test-token')->getJson('/api/appointments');

    $response->assertOk();
    $ids = collect($response->json())->pluck('id')->sort()->values()->all();
    $expected = collect($visibleAppointmentKeys)
        ->map(fn (string $key) => $fixture[$key])
        ->sort()
        ->values()
        ->all();

    expect($ids)->toBe($expected);
})->with([
    'patient' => ['patientA', ['appointmentA']],
    'doctor' => [
        'doctorA',
        ['appointmentA', 'appointmentAOtherPatient'],
    ],
    'secretary' => [
        'secretaryA',
        ['appointmentA', 'appointmentAOtherPatient'],
    ],
]);

it('denies horizontal access to an appointment by unrelated IDs', function (
    string $actorKey,
) {
    $fixture = appointmentSecurityFixture();
    appointmentSecurityAuthenticate(User::findOrFail($fixture[$actorKey]));

    $this->withToken('valid-test-token')
        ->getJson('/api/appointments/'.$fixture['appointmentA'])
        ->assertForbidden();
})->with([
    'unrelated patient' => ['patientB'],
    'doctor from another organization' => ['doctorB'],
    'secretary from another organization' => ['secretaryB'],
]);

it('denies every mutation route for an unrelated appointment', function () {
    $fixture = appointmentSecurityFixture();
    appointmentSecurityAuthenticate(User::findOrFail($fixture['patientB']));
    $uri = '/api/appointments/'.$fixture['appointmentA'];

    $this->withToken('valid-test-token')
        ->patchJson($uri, ['status' => 'cancelled'])
        ->assertForbidden();
    $this->withToken('valid-test-token')
        ->postJson($uri.'/decision', ['decision' => 'accept'])
        ->assertForbidden();
    $this->withToken('valid-test-token')
        ->postJson($uri.'/reschedule/check', [
            'date' => '2026-11-09',
            'start_time' => '09:00',
        ])
        ->assertForbidden();
    $this->withToken('valid-test-token')
        ->patchJson($uri.'/reschedule', [
            'date' => '2026-11-09',
            'start_time' => '09:00',
        ])
        ->assertForbidden();
    $this->withToken('valid-test-token')
        ->deleteJson($uri)
        ->assertForbidden();

    expect(Appointment::find($fixture['appointmentA']))->not->toBeNull();
});

it('allows a patient to cancel only their own appointment and ignores updated_by', function () {
    $fixture = appointmentSecurityFixture();
    $patient = User::findOrFail($fixture['patientA']);
    $appointment = Appointment::findOrFail($fixture['appointmentA']);
    appointmentSecurityAuthenticate($patient);

    $this->mock(AppointmentService::class, function (MockInterface $mock) use ($appointment, $patient) {
        $mock->shouldReceive('getById')
            ->once()
            ->with($appointment->id)
            ->andReturn($appointment);
        $mock->shouldReceive('update')
            ->once()
            ->with($appointment->id, [
                'status' => 'cancelled',
                'updated_by' => $patient->id,
            ])
            ->andReturn($appointment);
    });

    $this->withToken('valid-test-token')
        ->patchJson('/api/appointments/'.$appointment->id, [
            'status' => 'cancelled',
            'updated_by' => $fixture['doctorB'],
        ])
        ->assertOk();
});

it('does not allow a patient to edit the date of their own appointment', function () {
    $fixture = appointmentSecurityFixture();
    appointmentSecurityAuthenticate(User::findOrFail($fixture['patientA']));

    $this->withToken('valid-test-token')
        ->patchJson('/api/appointments/'.$fixture['appointmentA'], [
            'date' => '2026-11-09',
        ])
        ->assertForbidden();
});

it('derives creation state and audit fields for an authorized doctor', function () {
    $fixture = appointmentSecurityFixture();
    $doctor = User::findOrFail($fixture['doctorA']);
    appointmentSecurityAuthenticate($doctor);

    $this->mock(AppointmentService::class, function (MockInterface $mock) use ($doctor, $fixture) {
        $mock->shouldReceive('create')
            ->once()
            ->with([
                'id_schedule' => $fixture['scheduleA'],
                'id_patient' => $fixture['patientA'],
                'name_patient' => 'Valor no confiable',
                'date' => '2026-11-02',
                'start_time' => '09:00',
                'status' => 'accepted',
                'created_by' => $doctor->id,
                'updated_by' => $doctor->id,
            ])
            ->andReturn(['id' => 900]);
    });

    $this->withToken('valid-test-token')
        ->postJson('/api/appointments', [
            'id_schedule' => $fixture['scheduleA'],
            'id_patient' => $fixture['patientA'],
            'name_patient' => 'Valor no confiable',
            'date' => '2026-11-02',
            'start_time' => '09:00',
            'status' => 'requested',
            'created_by' => $fixture['doctorB'],
            'updated_by' => $fixture['doctorB'],
        ])
        ->assertCreated()
        ->assertJson(['id' => 900]);
});

it('denies creating an appointment on another doctors schedule', function () {
    $fixture = appointmentSecurityFixture();
    appointmentSecurityAuthenticate(User::findOrFail($fixture['doctorB']));

    $this->withToken('valid-test-token')
        ->postJson('/api/appointments', [
            'id_schedule' => $fixture['scheduleA'],
            'id_patient' => $fixture['patientA'],
            'date' => '2026-11-02',
            'start_time' => '09:00',
        ])
        ->assertForbidden();
});

it('rejects privileged state changes through the generic update endpoint', function () {
    $fixture = appointmentSecurityFixture();
    appointmentSecurityAuthenticate(User::findOrFail($fixture['doctorA']));

    $this->withToken('valid-test-token')
        ->patchJson('/api/appointments/'.$fixture['appointmentA'], [
            'status' => 'accepted',
        ])
        ->assertUnprocessable();
});

it('does not allow cancelling an appointment in a terminal state', function () {
    $fixture = appointmentSecurityFixture();
    $appointment = Appointment::findOrFail($fixture['appointmentA']);
    $appointment->update(['status' => 'rejected']);
    appointmentSecurityAuthenticate(User::findOrFail($fixture['patientA']));

    $this->withToken('valid-test-token')
        ->patchJson('/api/appointments/'.$appointment->id, [
            'status' => 'cancelled',
        ])
        ->assertUnprocessable()
        ->assertJsonValidationErrors('status');

    expect($appointment->fresh()->status)->toBe('rejected');
});
