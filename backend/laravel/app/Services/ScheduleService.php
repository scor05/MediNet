<?php

namespace App\Services;

use App\Repositories\ScheduleRepository;
use Illuminate\Validation\ValidationException;

class ScheduleService
{
    // Se inyecta el repositorio
    public function __construct(private ScheduleRepository $repository)
    {
    }

    // Se obtienen todos los horarios
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene un horario por su ID
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se obtienen los horarios de un doctor
    public function getByDoctor($doctorId)
    {
        return $this->repository->findByDoctor($doctorId);
    }

    // Se crea un nuevo horario validando que el doctor no tenga conflicto de horario
    public function create($data)
    {
        $conflict = $this->repository->hasConflict(
            $data['id_doctor'],
            $data['day_of_week'],
            $data['start_time'],
            $data['end_time']
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'schedule' => 'El doctor ya tiene un horario en ese día y hora.'
            ]);
        }

        return $this->repository->create($data);
    }

    // Se actualiza un horario validando que no haya conflicto
    public function update($id, $data)
    {
        if (isset($data['day_of_week']) || isset($data['start_time']) || isset($data['end_time'])) {
            $current = $this->repository->findById($id);

            $conflict = $this->repository->hasConflict(
                $current->id_doctor,
                $data['day_of_week'] ?? $current->day_of_week,
                $data['start_time']  ?? $current->start_time,
                $data['end_time']    ?? $current->end_time,
                $id
            );

            if ($conflict) {
                throw ValidationException::withMessages([
                    'schedule' => 'El doctor ya tiene un horario en ese día y hora.'
                ]);
            }
        }

        return $this->repository->update($id, $data);
    }

    // Se elimina un horario
    public function delete($id)
    {
        $this->repository->delete($id);
    }
}