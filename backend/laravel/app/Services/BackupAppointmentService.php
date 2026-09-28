<?php

namespace App\Services;

use App\Models\Appointment;
use App\Repositories\AppointmentRepository;
use App\Repositories\WaitlistRepository;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class BackupAppointmentService
{
    public function __construct(
        private WaitlistRepository $waitlistRepository,
        private AppointmentRepository $appointmentRepository,
        private UserService $userService,
        private AppointmentAvailabilityService $availabilityService,
        private AppointmentRealtimeService $realtimeService,
        private WaitlistRealtimeService $waitlistRealtimeService,
    ) {}

    public function create(int $waitlistId, int $patientId, array $data): Appointment
    {
        return DB::transaction(function () use ($waitlistId, $patientId, $data) {
            $waitlist = $this->waitlistRepository->findByIdForUpdate($waitlistId);

            if ($waitlist === null || (int) $waitlist->id_patient !== $patientId) {
                throw ValidationException::withMessages([
                    'waitlist' => ['No puedes modificar este registro de espera.'],
                ]);
            }
            if ($waitlist->status !== 'waiting') {
                throw ValidationException::withMessages([
                    'waitlist' => ['Este registro ya no está activo.'],
                ]);
            }
            if ($waitlist->id_backup_appointment !== null) {
                throw ValidationException::withMessages([
                    'waitlist' => ['Este registro ya tiene una cita de respaldo.'],
                ]);
            }
            if ($waitlist->backup_declined_at !== null) {
                throw ValidationException::withMessages([
                    'waitlist' => ['La oportunidad de crear una cita de respaldo ya fue descartada.'],
                ]);
            }

            $target = $this->appointmentRepository->findById(
                $waitlist->id_target_appointment
            );
            $schedule = $this->availabilityService->resolveAlternative(
                $target,
                $data['date'],
                $data['start_time'],
            );

            if ((int) $schedule->id !== (int) $data['id_schedule']) {
                throw ValidationException::withMessages([
                    'id_schedule' => ['El horario seleccionado ya no es válido.'],
                ]);
            }

            $patient = $this->userService->getById($patientId);
            $appointment = $this->appointmentRepository->create([
                'id_schedule' => $schedule->id,
                'id_patient' => $patientId,
                'name_patient' => $patient->name,
                'date' => $data['date'],
                'start_time' => $data['start_time'],
                'status' => 'backup_pending',
                'created_by' => $patientId,
                'updated_by' => $patientId,
            ]);

            $oldWaitlist = clone $waitlist;
            $waitlist = $this->waitlistRepository->update($waitlist->id, [
                'id_backup_appointment' => $appointment->id,
            ]);
            $this->realtimeService->created($appointment);
            $this->waitlistRealtimeService->updated($oldWaitlist, $waitlist);

            return $appointment;
        });
    }

    public function decline(int $waitlistId, int $patientId)
    {
        return DB::transaction(function () use ($waitlistId, $patientId) {
            $waitlist = $this->waitlistRepository->findByIdForUpdate($waitlistId);
            if ($waitlist === null || (int) $waitlist->id_patient !== $patientId) {
                throw ValidationException::withMessages([
                    'waitlist' => ['No puedes modificar este registro de espera.'],
                ]);
            }
            if ($waitlist->status !== 'waiting') {
                throw ValidationException::withMessages([
                    'waitlist' => ['Este registro ya no está activo.'],
                ]);
            }
            if ($waitlist->id_backup_appointment !== null) {
                throw ValidationException::withMessages([
                    'waitlist' => ['Este registro ya tiene una cita de respaldo.'],
                ]);
            }

            $oldWaitlist = clone $waitlist;
            $waitlist = $this->waitlistRepository->update($waitlist->id, [
                'backup_declined_at' => now(),
            ]);
            $this->waitlistRealtimeService->updated($oldWaitlist, $waitlist);

            return $waitlist;
        });
    }

    public function cancelWaitlist(int $waitlistId, int $patientId)
    {
        return DB::transaction(function () use ($waitlistId, $patientId) {
            $waitlist = $this->waitlistRepository->findByIdForUpdate($waitlistId);
            if ($waitlist === null || (int) $waitlist->id_patient !== $patientId) {
                throw ValidationException::withMessages([
                    'waitlist' => ['No puedes cancelar este registro de espera.'],
                ]);
            }

            $this->cancelBackup($waitlist->id_backup_appointment, $patientId);

            $oldWaitlist = clone $waitlist;
            $waitlist = $this->waitlistRepository->update($waitlist->id, [
                'status' => 'cancelled',
            ]);
            $this->waitlistRealtimeService->updated($oldWaitlist, $waitlist);

            return $waitlist;
        });
    }

    public function finalizeDueBackups(): int
    {
        $now = CarbonImmutable::now('America/Guatemala');
        $ids = $this->waitlistRepository->findDueBackupWaitlistIds(
            $now->toDateString(),
            $now->format('H:i:s'),
        );
        $processed = 0;

        foreach ($ids as $id) {
            DB::transaction(function () use ($id, &$processed): void {
                $waitlist = $this->waitlistRepository->findByIdForUpdate($id);
                if ($waitlist === null || $waitlist->status !== 'waiting') {
                    return;
                }

                $backup = $waitlist->id_backup_appointment === null
                    ? null
                    : $this->appointmentRepository->findById(
                        $waitlist->id_backup_appointment
                    );
                if ($backup === null) {
                    return;
                }

                if ($backup->status === 'backup_accepted') {
                    $oldWaitlist = clone $waitlist;
                    $waitlist = $this->waitlistRepository->update($waitlist->id, [
                        'status' => 'fulfilled',
                    ]);
                    $this->waitlistRealtimeService->updated(
                        $oldWaitlist,
                        $waitlist,
                    );
                } elseif ($backup->status === 'backup_pending') {
                    $this->cancelBackup($backup->id, $waitlist->id_patient);
                }
                $processed++;
            });
        }

        return $processed;
    }

    private function cancelBackup(mixed $appointmentId, int $updatedBy): void
    {
        if ($appointmentId === null) {
            return;
        }

        $appointment = $this->appointmentRepository->findById($appointmentId);
        if (! in_array($appointment->status, [
            'backup_pending',
            'backup_accepted',
        ], true)) {
            return;
        }

        $oldAppointment = clone $appointment;
        $appointment = $this->appointmentRepository->update($appointment->id, [
            'status' => 'backup_cancelled',
            'updated_by' => $updatedBy,
        ]);
        $this->realtimeService->updated($oldAppointment, $appointment);
    }
}
