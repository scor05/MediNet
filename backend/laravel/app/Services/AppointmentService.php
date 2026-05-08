<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Services\UserService;
use Illuminate\Validation\ValidationException;
use RuntimeException;

class AppointmentService
{
    // Se inyecta el repositorio
    public function __construct(private AppointmentRepository $repository, private UserService $userService)
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

    // Se obtienen las citas solicitadas que maneja una secretaria
    public function getPendingForSecretary(int $secretaryId): array
    {
        $clientId = $this->userService->getClientIdForUser($secretaryId);

        if (!$clientId) {
            throw new RuntimeException("La secretaria {$secretaryId} no tiene un cliente asociado.");
        }

        return $this->formatAppointments(
            $this->repository->findPendingForSecretary($clientId)
        );
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

        $idSchedule = $appointment->id_schedule;
        $date = $data['date'] ?? $appointment->date;
        $startTime = $data['start_time'] ?? $appointment->start_time;

        if (
            array_key_exists('date', $data) ||
            array_key_exists('start_time', $data)
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

        return $this->repository->update($id, $data);
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
    }

    private function formatAppointments(array $appointments): array
    {
        return array_map(function ($appointment) {
            return [
                'id' => $appointment->id,
                'date' => $appointment->date,
                'start_time' => $appointment->start_time,
                'status' => $appointment->status,
                'doctor' => [
                    'id' => $appointment->doctor_id,
                    'name' => $appointment->doctor_name,
                ],
                'patient' => [
                    'id' => $appointment->id_patient,
                    'name' => $appointment->patient_name,
                ],
                'clinic' => [
                    'id' => $appointment->clinic_id,
                    'name' => $appointment->clinic_name,
                ],
                'schedule_id' => $appointment->id_schedule,
            ];
        }, $appointments);
    }
}
