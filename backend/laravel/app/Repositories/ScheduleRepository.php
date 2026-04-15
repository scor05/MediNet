<?php

namespace App\Repositories;

use App\Models\Schedule;

class ScheduleRepository
{
    // Se obtienen los horarios de un doctor
    public function findByDoctor($doctorId)
    {
        return Schedule::select('schedules.*', 'clinics.name as clinic_name')
            ->join('clinics', 'schedules.id_clinic', '=', 'clinics.id')
            ->where('schedules.id_doctor', $doctorId)
            ->get();
    }

    // Se obtiene un horario por su ID
    public function findById($id)
    {
        return Schedule::findOrFail($id);
    }

    // Se crea un nuevo horario
    public function create($data)
    {
        return Schedule::create($data);
    }

    // Se actualiza un horario
    public function update($id, $data)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->update($data);
        return $schedule;
    }

    // Se elimina un horario
    public function delete($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->delete();
    }

    // Se verifica si el doctor ya tiene un horario en ese día y hora
    public function findOverlappingSchedule($doctorId, $dayOfWeek, $startTime, $endTime, $excludeId = null)
    {
        return Schedule::where('id_doctor', $doctorId)
            ->where('day_of_week', $dayOfWeek)
            ->where('is_active', true)
            ->when($excludeId, fn($q) => $q->where('id', '!=', $excludeId))
            ->where(function ($query) use ($startTime, $endTime) {
                $query->where('start_time', '<', $endTime)
                    ->where('end_time', '>', $startTime);
            })
            ->exists();
    }
}