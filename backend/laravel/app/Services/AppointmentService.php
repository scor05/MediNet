<?php

namespace App\Services;

use App\Models\Appointment;
use App\Repositories\AppointmentRepository;

class AppointmentService
{
    // Se inyecta el repositorio
    public function __construct(private AppointmentRepository $repository)
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
        return $this->repository->create($data);
    }

    // Se actualiza una cita
    public function update(int $id, array $data): ?Appointment
    {
        $this->validateConflict(
            $data['id_schedule'],
            $data['date'],
            $data['start_time'],
            $id
        );
        return $this->repository->update($id, $data);
    }

    // Se elimina una cita
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }

    // Se valida el conflicto de una cita (lógica pura, sin queries directos)
    private function validateConflict(
        int $idSchedule,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null
    ): void {
        $conflict = $this->repository->findConflict(
            $idSchedule,
            $date,
            $startTime,
            $ignoreAppointmentId
        );

        if ($conflict) {
            throw new \RuntimeException('Ya existe una cita en ese horario');
        }
    }
}
