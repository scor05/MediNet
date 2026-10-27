<?php

use App\Exceptions\AppointmentUnavailableException;
use App\Http\Middleware\SupabaseAuth;
use App\Models\User;
use App\Services\AppointmentRealtimeService;
use App\Services\NotificationService;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

// Estas pruebas llaman directamente al API, sin pasar por el frontend, para
// demostrar que las reglas de dominio de las citas se validan en el backend.

function appointmentDomainAuthenticate(int $userId): void
{
    $user = User::findOrFail($userId);

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

// Crea un cliente con clínica, doctor, secretaria, paciente y un horario de
// 08:00 a 12:00 con turnos de 30 minutos el mismo día de la semana que 'date'.
function appointmentDomainFixture(): array
{
    $suffix = Str::lower(Str::random(12));
    $now = now();
    $date = CarbonImmutable::now('America/Guatemala')->addWeeks(2)->startOfWeek();

    $createUser = fn (string $name) => DB::table('users')->insertGetId([
        'name' => $name,
        'email' => Str::slug($name)."-{$suffix}@example.test",
        'phone' => '5555-0000',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    $doctor = $createUser('Doctor Dominio');
    $secretary = $createUser('Secretaria Dominio');
    $patient = $createUser('Paciente Dominio');

    $client = DB::table('clients')->insertGetId([
        'nit' => "DOM-{$suffix}",
        'name' => 'Cliente Dominio',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $clinic = DB::table('clinics')->insertGetId([
        'name' => 'Clínica Dominio',
        'address' => 'Dirección de prueba',
        'phone' => "dom-{$suffix}",
        'email' => "clinica-{$suffix}@example.test",
        'id_client' => $client,
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    DB::table('client_users')->insert([
        ['id_client' => $client, 'id_user' => $doctor, 'role' => 1, 'is_admin' => false, 'is_active' => true],
        ['id_client' => $client, 'id_user' => $secretary, 'role' => 2, 'is_admin' => false, 'is_active' => true],
    ]);

    $schedule = DB::table('schedules')->insertGetId([
        'id_doctor' => $doctor,
        'id_clinic' => $clinic,
        'day_of_week' => $date->dayOfWeekIso - 1,
        'start_time' => '08:00',
        'end_time' => '12:00',
        'is_active' => true,
        'duration' => 30,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    return compact('doctor', 'secretary', 'patient', 'client', 'clinic', 'schedule') + [
        'date' => $date,
    ];
}

function appointmentDomainInsertAppointment(array $fixture, string $startTime, string $status = 'accepted'): int
{
    return DB::table('appointments')->insertGetId([
        'id_schedule' => $fixture['schedule'],
        'id_patient' => $fixture['patient'],
        'name_patient' => 'Paciente Dominio',
        'date' => $fixture['date']->toDateString(),
        'status' => $status,
        'start_time' => $startTime,
        'created_by' => $fixture['secretary'],
        'updated_by' => $fixture['secretary'],
        'created_at' => now(),
        'updated_at' => now(),
    ]);
}

function appointmentDomainCount(array $fixture): int
{
    return DB::table('appointments')->where('id_schedule', $fixture['schedule'])->count();
}

// Prepara el caso inválido y devuelve los campos del payload que se sobrescriben.
function appointmentDomainArrange(string $case, array $f): array
{
    return match ($case) {
        'past' => ['date' => CarbonImmutable::now('America/Guatemala')->subWeek()->toDateString()],
        'inactive_schedule' => tap([], fn () => DB::table('schedules')->where('id', $f['schedule'])->update(['is_active' => false])),
        'inactive_clinic' => tap([], fn () => DB::table('clinics')->where('id', $f['clinic'])->update(['is_active' => false])),
        'inactive_doctor' => tap([], fn () => DB::table('users')->where('id', $f['doctor'])->update(['is_active' => false])),
        'doctor_removed' => tap([], fn () => DB::table('client_users')->where('id_user', $f['doctor'])->update(['is_active' => false])),
        'wrong_day' => ['date' => $f['date']->addDay()->toDateString()],
        'before_start' => ['start_time' => '07:30'],
        'after_end' => ['start_time' => '12:00'],
        'misaligned' => ['start_time' => '09:15'],
        'blocked' => tap([], fn () => DB::table('schedule_blockades')->insert([
            'id_schedule' => $f['schedule'],
            'date' => $f['date']->toDateString(),
            'start_time' => '09:00',
            'end_time' => '10:00',
        ])),
        'overlap' => tap([], fn () => appointmentDomainInsertAppointment($f, '09:00')),
    };
}

it('rejects invalid appointments created by staff directly through the API', function (string $case, string $message) {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['secretary']);
    $payload = appointmentDomainArrange($case, $fixture) + [
        'id_schedule' => $fixture['schedule'],
        'name_patient' => 'Paciente sin cuenta',
        'date' => $fixture['date']->toDateString(),
        'start_time' => '09:00',
    ];
    $before = appointmentDomainCount($fixture);

    $this->withToken('valid-test-token')
        ->postJson('/api/appointments', $payload)
        ->assertUnprocessable()
        ->assertJson(['message' => $message]);

    expect(appointmentDomainCount($fixture))->toBe($before);
})->with([
    'fecha pasada' => ['past', AppointmentUnavailableException::PAST_BOOKING],
    'horario inactivo' => ['inactive_schedule', AppointmentUnavailableException::INACTIVE_SCHEDULE],
    'clínica inactiva' => ['inactive_clinic', AppointmentUnavailableException::INACTIVE_CLINIC],
    'médico inactivo' => ['inactive_doctor', AppointmentUnavailableException::INACTIVE_DOCTOR],
    'médico retirado del cliente' => ['doctor_removed', AppointmentUnavailableException::INACTIVE_DOCTOR],
    'día de la semana incorrecto' => ['wrong_day', AppointmentUnavailableException::WRONG_DAY],
    'antes del inicio del horario' => ['before_start', AppointmentUnavailableException::OUTSIDE_RANGE],
    'termina después del fin del horario' => ['after_end', AppointmentUnavailableException::OUTSIDE_RANGE],
    'no alineada con la duración' => ['misaligned', AppointmentUnavailableException::MISALIGNED],
    'bloqueo del horario' => ['blocked', AppointmentUnavailableException::BLOCKED],
    'solapamiento con otra cita' => ['overlap', AppointmentUnavailableException::OCCUPIED],
]);

it('rejects appointment dates that are not in Y-m-d format', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['secretary']);

    $this->withToken('valid-test-token')
        ->postJson('/api/appointments', [
            'id_schedule' => $fixture['schedule'],
            'name_patient' => 'Paciente sin cuenta',
            'date' => $fixture['date']->format('d/m/Y'),
            'start_time' => '09:00',
        ])
        ->assertUnprocessable()
        ->assertJsonValidationErrors('date');
});

it('rejects invalid public appointment requests directly through the API', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['patient']);

    $this->withToken('valid-test-token')
        ->postJson('/api/public/appointments', [
            'id_schedule' => $fixture['schedule'],
            'date' => $fixture['date']->toDateString(),
            'start_time' => '09:15',
        ])
        ->assertUnprocessable()
        ->assertJson(['message' => AppointmentUnavailableException::MISALIGNED]);

    expect(appointmentDomainCount($fixture))->toBe(0);
});

it('creates a valid public request as requested even if the client sends a privileged status', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['patient']);
    $this->mock(NotificationService::class)->shouldIgnoreMissing();
    $this->mock(AppointmentRealtimeService::class)->shouldIgnoreMissing();

    $response = $this->withToken('valid-test-token')
        ->postJson('/api/public/appointments', [
            'id_schedule' => $fixture['schedule'],
            'date' => $fixture['date']->toDateString(),
            'start_time' => '09:30',
            'status' => 'accepted',
        ])
        ->assertCreated();

    expect(DB::table('appointments')->where('id', $response->json('id'))->value('status'))
        ->toBe('requested');
});

it('creates a valid staff appointment with the status derived by the backend', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['secretary']);
    $this->mock(AppointmentRealtimeService::class)->shouldIgnoreMissing();

    $response = $this->withToken('valid-test-token')
        ->postJson('/api/appointments', [
            'id_schedule' => $fixture['schedule'],
            'name_patient' => 'Paciente sin cuenta',
            'date' => $fixture['date']->toDateString(),
            'start_time' => '11:30',
            'status' => 'backup_accepted',
        ])
        ->assertCreated();

    expect(DB::table('appointments')->where('id', $response->json('id'))->value('status'))
        ->toBe('accepted');
});

it('rejects rescheduling an appointment to a past date', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['secretary']);
    $appointment = appointmentDomainInsertAppointment($fixture, '09:00');

    $this->withToken('valid-test-token')
        ->patchJson("/api/appointments/{$appointment}", [
            'date' => $fixture['date']->subWeeks(4)->toDateString(),
        ])
        ->assertUnprocessable()
        ->assertJson(['message' => AppointmentUnavailableException::PAST]);
});

it('rejects rescheduling an appointment when the clinic is inactive', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['secretary']);
    $appointment = appointmentDomainInsertAppointment($fixture, '09:00');
    DB::table('clinics')->where('id', $fixture['clinic'])->update(['is_active' => false]);

    $this->withToken('valid-test-token')
        ->patchJson("/api/appointments/{$appointment}/reschedule", [
            'date' => $fixture['date']->toDateString(),
            'start_time' => '10:00',
        ])
        ->assertUnprocessable()
        ->assertJson(['message' => AppointmentUnavailableException::INVALID_SCHEDULE]);
});

it('rejects privileged statuses through the generic update endpoint', function () {
    $fixture = appointmentDomainFixture();
    appointmentDomainAuthenticate($fixture['secretary']);
    $appointment = appointmentDomainInsertAppointment($fixture, '09:00', 'requested');

    $this->withToken('valid-test-token')
        ->patchJson("/api/appointments/{$appointment}", ['status' => 'accepted'])
        ->assertUnprocessable()
        ->assertJsonValidationErrors('status');

    expect(DB::table('appointments')->where('id', $appointment)->value('status'))->toBe('requested');
});
