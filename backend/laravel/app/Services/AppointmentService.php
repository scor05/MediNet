<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use Illuminate\Support\Facades\DB;

class AppointmentService
{
    // Se inyecta el repositorio
    public function __construct(
        private AppointmentRepository $repository,
        private UserService $userService,
        private ScheduleBlockadeRepository $blockadeRepository,
        private NotificationService $notificationService,
        private WaitlistPromotionService $waitlistPromotionService,
        private AppointmentAvailabilityService $availabilityService,
        private AppointmentRealtimeService $realtimeService,
    ) {}

    // Se obtienen todas las citas
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene una cita por su id
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea una nueva cita
    public function create($data)
    {
        $this->availabilityService->ensureAvailable(
            $data['id_schedule'],
            $data['date'],
            $data['start_time']
        );

        if (isset($data['id_patient'])) {
            $data['name_patient'] = $this->userService->getById($data['id_patient'])?->name;
        }

        $appointment = $this->repository->create($data);

        if (isset($data['id_patient'])) {
            $this->notifyCreatedAppointment($appointment->id, $data['id_patient']);
        }

        $this->realtimeService->created($appointment);

        return $appointment;
    }

    private function notifyCreatedAppointment(int $appointmentId, int $patientId): void
    {
        $context = $this->repository->findNotificationContext($appointmentId);

        $this->notificationService->create([
            'id_user' => $patientId,
            'type' => 'acceptance',
            'message' => 'Se ha agendado una cita con el Dr. '
                .$context->doctor_name
                .' el '
                .$this->formatDate($context->date)
                .' a las '
                .$this->formatTime($context->start_time)
                .'.',
            'channel' => 'push',
        ]);
    }

    // Se actualiza una cita
    public function update(int $id, array $data)
    {
        $appointment = $this->repository->findById($id);
        $oldAppointment = clone $appointment;

        $date = $data['date'] ?? $appointment->date;
        $startTime = $data['start_time'] ?? $appointment->start_time;

        if (array_key_exists('date', $data) || array_key_exists('start_time', $data)) {
            $schedule = $this->availabilityService->resolveReschedule(
                $appointment,
                (string) $date,
                (string) $startTime,
            );
            $data['id_schedule'] = $schedule->id;
        } elseif (($data['status'] ?? null) === 'accepted') {
            $this->availabilityService->ensureAvailable(
                $appointment->id_schedule,
                $date,
                $startTime,
                $id
            );
        }

        if (array_key_exists('id_patient', $data)) {
            $data['name_patient'] = $this->userService->getById($data['id_patient'])?->name;
        }

        $appointment = DB::transaction(function () use ($id, $data, $oldAppointment) {
            $appointment = $this->repository->update($id, $data);
            $this->notifyUpdatedAppointment($oldAppointment, $appointment);
            $this->waitlistPromotionService->promoteIfFreed(
                $oldAppointment,
                $appointment
            );
            $this->realtimeService->updated($oldAppointment, $appointment);

            return $appointment;
        });

        return $appointment;
    }

    public function checkReschedule(
        int $id,
        string $date,
        string $startTime,
    ): void {
        $appointment = $this->repository->findById($id);
        $this->availabilityService->resolveReschedule(
            $appointment,
            $date,
            $startTime,
        );
    }

    public function reschedule(
        int $id,
        string $date,
        string $startTime,
        int $updatedBy,
    ) {
        return DB::transaction(function () use (
            $id,
            $date,
            $startTime,
            $updatedBy,
        ) {
            $appointment = $this->repository->findById($id);
            $oldAppointment = clone $appointment;
            $schedule = $this->availabilityService->resolveReschedule(
                $appointment,
                $date,
                $startTime,
            );

            $appointment = $this->repository->update($id, [
                'id_schedule' => $schedule->id,
                'date' => $date,
                'start_time' => $startTime,
                'updated_by' => $updatedBy,
            ]);

            $this->notifyUpdatedAppointment($oldAppointment, $appointment);
            $this->waitlistPromotionService->promoteIfFreed(
                $oldAppointment,
                $appointment,
            );
            $this->realtimeService->updated($oldAppointment, $appointment);

            return $appointment;
        });
    }

    private function notifyUpdatedAppointment($oldAppointment, $newAppointment)
    {
        $changes = $this->getAppointmentChanges($oldAppointment, $newAppointment);

        if (empty($changes)) {
            return;
        }

        $ctx = $this->repository->findNotificationContext($newAppointment->id);
        $type = $this->getNotificationType($oldAppointment, $newAppointment);
        $changesText = implode("\n", $changes);

        // Enviar notificación al paciente
        $patient_msg = "Su cita con el Dr.{$ctx->doctor_name} el {$this->formatDate($ctx->date)} ha cambiado:\n{$changesText}";

        if ($newAppointment->id_patient !== null) {
            $this->notificationService->create([
                'id_user' => $newAppointment->id_patient,
                'type' => $type,
                'message' => $patient_msg,
                'channel' => 'push',
            ]);
        }

        if ($this->wasRescheduled($oldAppointment, $newAppointment)) {
            $doctorMessage = "La cita con {$ctx->patient_name} fue reprogramada para el "
                .$this->formatDate($ctx->date)
                .' a las '
                .$this->formatTime($ctx->start_time)
                ." en {$ctx->clinic_name}.";

            $this->notificationService->create([
                'id_user' => $ctx->doctor_id,
                'type' => 'reschedule',
                'message' => $doctorMessage,
                'channel' => 'push',
            ]);
        }

        // Enviar notificación a secretarias
        $secretary_msg = "La cita con el paciente {$ctx->patient_name} con el Dr.{$ctx->doctor_name} el {$this->formatDate($ctx->date)} ha cambiado:\n{$changesText}";
        $secretaries = $this->repository->findSecretariesByClient($ctx->client_id);

        foreach ($secretaries as $s) {
            $this->notificationService->create([
                'id_user' => $s->id,
                'type' => $type,
                'message' => $secretary_msg,
                'channel' => 'push',
            ]);
        }
    }

    private function getAppointmentChanges($oldAppointment, $newAppointment): array
    {
        $changes = [];

        if ($oldAppointment->status !== $newAppointment->status) {
            $changes[] = 'Estado: '
                .$this->formatStatus($oldAppointment->status)
                .' -> '
                .$this->formatStatus($newAppointment->status);
        }

        if ($oldAppointment->date !== $newAppointment->date) {
            $changes[] = 'Fecha: '
                .$this->formatDate($oldAppointment->date)
                .' -> '
                .$this->formatDate($newAppointment->date);
        }

        if ($this->formatTime($oldAppointment->start_time) !== $this->formatTime($newAppointment->start_time)) {
            $changes[] = 'Hora de inicio: '
                .$this->formatTime($oldAppointment->start_time)
                .' -> '
                .$this->formatTime($newAppointment->start_time);
        }

        if ($oldAppointment->name_patient !== $newAppointment->name_patient) {
            $changes[] = 'Paciente: '
                .$oldAppointment->name_patient
                .' -> '
                .$newAppointment->name_patient;
        }

        return $changes;
    }

    private function wasRescheduled($oldAppointment, $newAppointment): bool
    {
        return $oldAppointment->id_schedule !== $newAppointment->id_schedule
            || (string) $oldAppointment->date !== (string) $newAppointment->date
            || $this->formatTime($oldAppointment->start_time)
                !== $this->formatTime($newAppointment->start_time);
    }

    private function getNotificationType($oldAppointment, $newAppointment): string
    {
        if ($oldAppointment->status !== $newAppointment->status) {
            return match ($newAppointment->status) {
                'accepted' => 'acceptance',
                'rejected' => 'rejection',
                'cancelled' => 'cancellation',
                'rescheduled' => 'reschedule',
                default => 'reminder',
            };
        }

        if (
            $oldAppointment->date !== $newAppointment->date ||
            $this->formatTime($oldAppointment->start_time) !== $this->formatTime($newAppointment->start_time)
        ) {
            return 'reschedule';
        }

        return 'reminder';
    }

    private function formatDate($date): string
    {
        return date('d/m/Y', strtotime((string) $date));
    }

    private function formatTime($time): string
    {
        return substr((string) $time, 0, 5);
    }

    private function formatStatus(string $status): string
    {
        return match ($status) {
            'requested' => 'Solicitada',
            'accepted' => 'Aceptada',
            'rejected' => 'Rechazada',
            'cancelled' => 'Cancelada',
            'rescheduled' => 'Recalendarizada',
            default => $status,
        };
    }

    // Se elimina una cita
    public function delete(int $id)
    {
        DB::transaction(function () use ($id): void {
            $appointment = $this->repository->findById($id);
            $this->repository->delete($id);
            $this->realtimeService->deleted($appointment);
        });
    }
}
