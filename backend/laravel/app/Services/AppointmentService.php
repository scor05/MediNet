<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Services\UserService;
use App\Services\NotificationService;
use App\Services\WaitlistService;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class AppointmentService
{
    // Se inyecta el repositorio
    public function __construct(private AppointmentRepository $repository,
        private UserService $userService,
        private ScheduleBlockadeRepository $blockadeRepository,
        private NotificationService $notificationService,
        private WaitlistService $waitlistService)
    {
    }

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
        $this->validateConflict(
            $data['id_schedule'],
            $data['date'],
            $data['start_time']
        );

        if (array_key_exists('id_patient', $data)) {
            $data['name_patient'] = $this->userService->getById($data['id_patient'])?->name;
        }

        return $this->repository->create($data);
    }

    // Se actualiza una cita
    public function update(int $id, array $data)
    {
        $appointment = $this->repository->findById($id);
        $oldAppointment = clone $appointment;

        $idSchedule = $appointment->id_schedule;
        $date = $data['date'] ?? $appointment->date;
        $startTime = $data['start_time'] ?? $appointment->start_time;

        if (
            array_key_exists('date', $data) ||
            array_key_exists('start_time', $data) ||
            (($data['status'] ?? null) === 'accepted')
        ) {
            $this->validateConflict(
                $idSchedule,
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

            return $appointment;
        });

        // Notificar a pacientes en lista de espera si se liberó el horario
        $this->notifyWaitlistIfSlotFreed($oldAppointment, $appointment);

        return $appointment;
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
                . $this->formatStatus($oldAppointment->status)
                . ' -> '
                . $this->formatStatus($newAppointment->status);
        }

        if ($oldAppointment->date !== $newAppointment->date) {
            $changes[] = 'Fecha: '
                . $this->formatDate($oldAppointment->date)
                . ' -> '
                . $this->formatDate($newAppointment->date);
        }

        if ($this->formatTime($oldAppointment->start_time) !== $this->formatTime($newAppointment->start_time)) {
            $changes[] = 'Hora de inicio: '
                . $this->formatTime($oldAppointment->start_time)
                . ' -> '
                . $this->formatTime($newAppointment->start_time);
        }

        if ($oldAppointment->name_patient !== $newAppointment->name_patient) {
            $changes[] = 'Paciente: '
                . $oldAppointment->name_patient
                . ' -> '
                . $newAppointment->name_patient;
        }

        return $changes;
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

    /**
     * Si la cita cambió a cancelled o rejected, notifica a los pacientes
     * en lista de espera que el horario se ha liberado.
     */
    private function notifyWaitlistIfSlotFreed($oldAppointment, $newAppointment): void
    {
        $freedStatuses = ['cancelled', 'rejected'];

        $statusChanged = $oldAppointment->status !== $newAppointment->status;
        $isNowFreed = in_array($newAppointment->status, $freedStatuses);

        if ($statusChanged && $isNowFreed) {
            $this->waitlistService->notifySlotFreed($newAppointment->id);
        }
    }

    // Se elimina una cita
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }

    // Se valida si la cita por crear/actualizar no genera conflictos
    private function validateConflict(
        int $idSchedule,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null
    ): void {
        $conflict = $this->repository->findAppointment(
            $idSchedule,
            $date,
            $startTime,
            $ignoreAppointmentId
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'start_time' => ['Ya existe una cita en ese horario'],
            ]);
        }

        $blockade = $this->blockadeRepository->findBlockadeAtTime(
            $idSchedule,
            $date,
            $startTime
        );

        if ($blockade) {
            throw ValidationException::withMessages([
                'start_time' => ['Ese horario está bloqueado y no permite nuevas citas.'],
            ]);
        }
    }
}
