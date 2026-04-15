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

    // Se obtienen los horarios de un doctor
    public function getByDoctor($doctorId)
    {
        return $this->repository->findByDoctor($doctorId);
    }

    // Se obtiene un horario por su ID
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea un nuevo horario validando que el doctor no tenga conflicto de horario
    public function create($data)
    {
        $this->validateConflict(
            $data['id_doctor'],
            $data['day_of_week'],
            $data['start_time'],
            $data['end_time']
        );

        return $this->repository->create($data);
    }

    // Se actualiza un horario validando que no haya conflicto
    public function update($id, $data)
    {
        $schedule = $this->repository->findById($id);

        $idDoctor = $schedule->id_doctor;
        $dayOfWeek = $schedule->dayOfWeek;
        $startTime = $data['start_time'] ?? $schedule->start_time;
        $endTime = $data['end_time'] ?? $schedule->end_time;

        if (
            array_key_exists('start_time', $data) ||
            array_key_exists('end_time', $data)
        ) {
            $this->validateConflict(
                $idDoctor,
                $dayOfWeek,
                $startTime,
                $endTime,
                $id
            );
        }

        return $this->repository->update($id, $data);
    }

    // Se elimina un horario
    public function delete($id)
    {
        $this->repository->delete($id);
    }

    private function validateConflict(
        int $doctorId,
        int $dayOfWeek,
        string $startTime,
        string $endTime,
        ?int $excludeId = null
    ): void {
        $conflict = $this->repository->findOverlappingSchedule(
            $doctorId,
            $dayOfWeek,
            $startTime,
            $endTime,
            $excludeId
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'start_time' => ['Ya existe un horario en ese día y hora.'],
                'end_time' => ['Ya existe un horario en ese día y hora.'],
            ]);
        }
    }
}