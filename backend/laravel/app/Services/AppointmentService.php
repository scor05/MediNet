<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Services\UserService;
use Illuminate\Validation\ValidationException;

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
}
