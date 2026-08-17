<?php

namespace App\Services;

use App\Repositories\WaitlistRepository;
use App\Services\NotificationService;
use Illuminate\Validation\ValidationException;

class WaitlistService
{
    private const VALID_STATUSES = [
        'active',
        'notified',
        'expired',
        'fulfilled',
        'cancelled',
    ];

    // Se inyectan las dependencias
    public function __construct(
        private WaitlistRepository $repository,
        private NotificationService $notificationService
    ) {
    }

    // Se obtienen todos los registros
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene un registro por su id
    public function getById(int $id)
    {
        return $this->repository->findById($id);
    }

    // Se obtienen los registros de un paciente
    public function getByPatient(int $patientId)
    {
        return $this->repository->findByPatient($patientId);
    }

    // Se crea un nuevo registro de lista de espera
    public function create(array $data)
    {
        $this->validateStatus($data['status'] ?? 'active');

        return $this->repository->create($data);
    }

    // Se actualiza un registro
    public function update(int $id, array $data)
    {
        if (isset($data['status'])) {
            $this->validateStatus($data['status']);
        }

        return $this->repository->update($id, $data);
    }

    // Se elimina un registro
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }

    /**
     * Notifica a los pacientes en lista de espera cuando se libera un horario.
     * Se llama automáticamente cuando una cita es cancelada o rechazada.
     */
    public function notifySlotFreed(int $appointmentId): void
    {
        $activeWaitlists = $this->repository->findActiveByTargetAppointment($appointmentId);

        foreach ($activeWaitlists as $waitlist) {
            $ctx = $this->repository->findNotificationContext($waitlist->id);

            if (!$ctx) {
                continue;
            }

            $message = "¡Se ha liberado un espacio! "
                . "Dr. {$ctx->doctor_name}, "
                . "Clínica {$ctx->clinic_name}, "
                . "{$this->formatDate($ctx->date)} "
                . "a las {$this->formatTime($ctx->start_time)}. "
                . "El horario que solicitaste ya está disponible.";

            $this->notificationService->dispatch(
                'waitlist_alert',
                $waitlist->id_patient,
                $message
            );

            // Actualizar el status del waitlist a 'notified'
            $this->repository->update($waitlist->id, ['status' => 'notified']);
        }
    }

    // Valida que el status sea válido
    private function validateStatus(string $status): void
    {
        if (!in_array($status, self::VALID_STATUSES)) {
            throw ValidationException::withMessages([
                'status' => ['Estado de lista de espera inválido.'],
            ]);
        }
    }

    // Formatea la fecha para el mensaje de notificación
    private function formatDate($date): string
    {
        return date('d/m/Y', strtotime((string) $date));
    }

    // Formatea la hora para el mensaje de notificación
    private function formatTime($time): string
    {
        return substr((string) $time, 0, 5);
    }
}
