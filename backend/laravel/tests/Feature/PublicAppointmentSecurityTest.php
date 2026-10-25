<?php

use App\Http\Middleware\SupabaseAuth;
use App\Models\User;
use App\Services\PublicService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Mockery\MockInterface;

it('rejects public appointment creation without an access token', function () {
    $this->postJson('/api/public/appointments', [
        'id_schedule' => 7,
        'date' => '2026-11-02',
        'start_time' => '09:00',
    ])->assertUnauthorized()
        ->assertJson([
            'message' => 'Token no proporcionado',
        ]);
});

it('uses the authenticated patient identity instead of client supplied identity fields', function () {
    $doctorId = DB::table('users')->insertGetId([
        'name' => 'Doctor de Prueba',
        'email' => 'public-appointment-doctor@example.test',
        'is_active' => true,
        'created_at' => now(),
        'updated_at' => now(),
    ]);
    $clientId = DB::table('clients')->insertGetId([
        'nit' => 'SEC-PUBLIC-APPOINTMENT',
        'name' => 'Cliente de Prueba',
        'is_active' => true,
        'created_at' => now(),
        'updated_at' => now(),
    ]);
    $clinicId = DB::table('clinics')->insertGetId([
        'name' => 'Clínica de Prueba',
        'address' => 'Dirección de prueba',
        'phone' => '5555-0101',
        'email' => 'public-appointment-clinic@example.test',
        'id_client' => $clientId,
        'is_active' => true,
        'created_at' => now(),
        'updated_at' => now(),
    ]);
    $scheduleId = DB::table('schedules')->insertGetId([
        'id_doctor' => $doctorId,
        'id_clinic' => $clinicId,
        'day_of_week' => 1,
        'start_time' => '08:00',
        'end_time' => '12:00',
        'is_active' => true,
        'duration' => 30,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    $authenticatedPatient = new User;
    $authenticatedPatient->id = 19;
    $authenticatedPatient->name = 'Paciente Autenticado';

    app()->instance(SupabaseAuth::class, new class($authenticatedPatient)
    {
        public function __construct(private User $patient) {}

        public function handle(Request $request, Closure $next)
        {
            $request->setUserResolver(fn () => $this->patient);

            return $next($request);
        }
    });

    $this->mock(PublicService::class, function (MockInterface $mock) use ($authenticatedPatient, $scheduleId) {
        $mock->shouldReceive('createAppointment')
            ->once()
            ->with(
                [
                    'id_schedule' => $scheduleId,
                    'date' => '2026-11-02',
                    'start_time' => '09:00',
                ],
                $authenticatedPatient,
            )
            ->andReturn(['id' => 501]);
    });

    $this->withToken('valid-test-token')
        ->postJson('/api/public/appointments', [
            'id_schedule' => $scheduleId,
            'id_patient' => 999,
            'name_patient' => 'Paciente Suplantado',
            'created_by' => 999,
            'updated_by' => 999,
            'date' => '2026-11-02',
            'start_time' => '09:00',
        ])
        ->assertCreated()
        ->assertJson(['id' => 501]);
});
