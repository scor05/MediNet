<?php

namespace App\Services;

use App\Repositories\ScheduleRepository;
use Illuminate\Support\Facades\DB;
use LogicException;

class AppointmentBookingLockService
{
    public function __construct(
        private ScheduleRepository $scheduleRepository,
    ) {}

    /**
     * Serializes every availability check that can affect the same doctor,
     * schedule or patient on a given date. PostgreSQL releases these advisory
     * locks automatically when the surrounding transaction finishes.
     */
    public function acquire(
        int $scheduleId,
        string $date,
        ?int $patientId = null,
    ): void {
        $this->acquireMany([[
            'schedule_id' => $scheduleId,
            'date' => $date,
            'patient_id' => $patientId,
        ]]);
    }

    /**
     * @param  array<int, array{schedule_id: int, date: string, patient_id?: ?int}>  $scopes
     */
    public function acquireMany(array $scopes): void
    {
        if (DB::transactionLevel() === 0) {
            throw new LogicException(
                'El bloqueo de disponibilidad requiere una transacción activa.'
            );
        }

        $keys = [];
        $scheduleIds = [];

        foreach ($scopes as $scope) {
            $scheduleId = (int) $scope['schedule_id'];
            $date = (string) $scope['date'];
            $patientId = $scope['patient_id'] ?? null;
            $schedule = $this->scheduleRepository->findById($scheduleId);

            $keys[] = "appointment:doctor:{$schedule->id_doctor}:date:{$date}";
            $keys[] = "appointment:schedule:{$scheduleId}:date:{$date}";
            $scheduleIds[] = $scheduleId;

            if ($patientId !== null) {
                $keys[] = "appointment:patient:{$patientId}:date:{$date}";
            }
        }

        $keys = array_values(array_unique($keys));
        sort($keys, SORT_STRING);

        if (DB::connection()->getDriverName() === 'pgsql') {
            foreach ($keys as $key) {
                DB::select(
                    'SELECT pg_advisory_xact_lock(hashtextextended(CAST(? AS text), 0))',
                    [$key],
                );
            }

            return;
        }

        // The production database is PostgreSQL. This keeps tests and local
        // alternatives safe for requests targeting the exact same schedule.
        $scheduleIds = array_values(array_unique($scheduleIds));
        sort($scheduleIds, SORT_NUMERIC);

        foreach ($scheduleIds as $scheduleId) {
            $this->scheduleRepository->lockById($scheduleId);
        }
    }
}
