<?php

namespace App\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Models\Appointment;
use App\Repositories\AppointmentRepository;
use App\Repositories\WaitlistRepository;

class WaitlistPromotionService
{
    public function __construct(
        private WaitlistRepository $waitlistRepository,
        private AppointmentRepository $appointmentRepository,
        private UserService $userService,
        private NotificationService $notificationService,
        private AppointmentAvailabilityService $availabilityService,
        private AppointmentRealtimeService $realtimeService,
        private WaitlistRealtimeService $waitlistRealtimeService,
    ) {}

    public function promoteIfFreed(
        Appointment $oldAppointment,
        Appointment $newAppointment
    ): ?Appointment {
        if (! $this->slotWasFreed($oldAppointment, $newAppointment)) {
            return null;
        }

        $waitlist = $this->waitlistRepository
            ->findFirstWaitingForFreedAppointment($oldAppointment->id);

        if ($waitlist === null) {
            return null;
        }

        try {
            $this->availabilityService->ensureAvailable(
                $oldAppointment->id_schedule,
                (string) $oldAppointment->date,
                $this->formatTime($oldAppointment->start_time),
                $oldAppointment->id,
                (int) $waitlist->id_patient,
            );
        } catch (AppointmentUnavailableException) {
            return null;
        }

        $patient = $this->userService->getById($waitlist->id_patient);
        $actorId = $newAppointment->updated_by ?? $waitlist->id_patient;

        $promotedAppointment = $this->appointmentRepository->create([
            'id_schedule' => $oldAppointment->id_schedule,
            'id_patient' => $waitlist->id_patient,
            'name_patient' => $patient->name,
            'date' => (string) $oldAppointment->date,
            'start_time' => $this->formatTime($oldAppointment->start_time),
            'status' => 'accepted',
            'created_by' => $actorId,
            'updated_by' => $actorId,
        ]);

        $oldWaitlist = clone $waitlist;
        $waitlist = $this->waitlistRepository->update($waitlist->id, [
            'id_fallback_appointment' => $promotedAppointment->id,
            'status' => 'fulfilled',
        ]);
        $this->waitlistRealtimeService->updated($oldWaitlist, $waitlist);

        if ($waitlist->id_backup_appointment !== null) {
            $backup = $this->appointmentRepository->findById(
                $waitlist->id_backup_appointment
            );
            if (in_array($backup->status, [
                'backup_pending',
                'backup_accepted',
            ], true)) {
                $oldBackup = clone $backup;
                $backup = $this->appointmentRepository->update($backup->id, [
                    'status' => 'backup_cancelled',
                    'updated_by' => $actorId,
                ]);
                $this->realtimeService->updated($oldBackup, $backup);
            }
        }

        $context = $this->appointmentRepository
            ->findNotificationContext($promotedAppointment->id);

        $this->notificationService->dispatch(
            'waitlist_alert',
            $waitlist->id_patient,
            'Se te asignó el horario liberado con el Dr. '
                .$context->doctor_name
                .', Clínica '
                .$context->clinic_name
                .', el '
                .$this->formatDate($context->date)
                .' a las '
                .$this->formatTime($context->start_time)
                .'.',
        );
        $this->realtimeService->created($promotedAppointment);

        return $promotedAppointment;
    }

    private function slotWasFreed(
        Appointment $oldAppointment,
        Appointment $newAppointment
    ): bool {
        $wasHoldingSlot = in_array(
            $oldAppointment->status,
            [
                'accepted',
                'requested',
                'rescheduled',
                'backup_pending',
                'backup_accepted',
            ],
            true
        );

        if (! $wasHoldingSlot) {
            return false;
        }

        $wasCancelled = ! in_array($oldAppointment->status, [
            'cancelled',
            'rejected',
            'backup_cancelled',
        ], true) && in_array($newAppointment->status, [
            'cancelled',
            'rejected',
            'backup_cancelled',
        ], true);
        $wasMoved = $oldAppointment->id_schedule !== $newAppointment->id_schedule
            || (string) $oldAppointment->date !== (string) $newAppointment->date
            || $this->formatTime($oldAppointment->start_time)
                !== $this->formatTime($newAppointment->start_time);

        return $wasCancelled || $wasMoved;
    }

    private function formatDate($date): string
    {
        return date('d/m/Y', strtotime((string) $date));
    }

    private function formatTime($time): string
    {
        return substr((string) $time, 0, 5);
    }
}
