<?php

namespace App\Services;

use App\Repositories\ScheduleBlockadeRepository;
use Illuminate\Validation\ValidationException;

class ScheduleBlockadeService
{
    // Se inyecta el repositorio
    public function __construct(private ScheduleBlockadeRepository $repository)
    {
    }

    // Se obtienen los bloqueos de un schedule en una fecha
    public function getByScheduleAndDate(int $scheduleId, string $date)
    {
        return $this->repository->findByScheduleAndDate($scheduleId, $date);
    }

    // Se crea un nuevo bloqueo validando que no se solape con citas aceptadas
    public function create(array $data)
    {
        $overlapping = $this->repository->findOverlappingAppointments(
            $data['id_schedule'],
            $data['date'],
            $data['start_time'],
            $data['end_time']
        );

        if ($overlapping->isNotEmpty()) {
            throw ValidationException::withMessages([
                'start_time' => ['El rango de bloqueo se solapa con citas ya aceptadas en ese horario.'],
            ]);
        }

        return $this->repository->create($data);
    }

    // Se elimina un bloqueo
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }
}
