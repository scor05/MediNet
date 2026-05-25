<?php

namespace App\Repositories;

use App\Models\ScheduleBlockade;
use App\Models\Appointment;

class ScheduleBlockadeRepository
{
    // Se obtienen los bloqueos de un schedule en una fecha específica
    public function findByScheduleAndDate(int $scheduleId, string $date)
    {
        return ScheduleBlockade::where('id_schedule', $scheduleId)
            ->where('date', $date)
            ->get();
    }

    // Se obtiene un bloqueo por su id
    public function findById(int $id)
    {
        return ScheduleBlockade::findOrFail($id);
    }

    // Se crea un nuevo bloqueo
    public function create(array $data)
    {
        return ScheduleBlockade::create($data);
    }

    // Se elimina un bloqueo
    public function delete(int $id)
    {
        $blockade = ScheduleBlockade::findOrFail($id);
        $blockade->delete();
    }

    // Se busca si una hora cae dentro de algún bloqueo activo
    public function findBlockadeAtTime(int $scheduleId, string $date, string $startTime)
    {
        return ScheduleBlockade::where('id_schedule', $scheduleId)
            ->where('date', $date)
            ->where('start_time', '<=', $startTime)
            ->where('end_time', '>', $startTime)
            ->first();
    }

    // Se buscan citas aceptadas que se solapan con el rango del bloqueo
    public function findOverlappingAppointments(
        int $scheduleId,
        string $date,
        string $startTime,
        string $endTime
    ) {
        return Appointment::where('id_schedule', $scheduleId)
            ->where('date', $date)
            ->where('status', 'accepted')
            ->where('start_time', '<', $endTime)
            ->where('start_time', '>=', $startTime)
            ->get();
    }
}
