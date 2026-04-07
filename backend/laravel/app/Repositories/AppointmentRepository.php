<?php

namespace App\Repositories;

use App\Models\Appointment;

class AppointmentRepository
{
    // Se obtienen todas las citas
    public function findAll()
    {
        return Appointment::all();
    }

    // Se obtiene una cita por su id
    public function findById($id)
    {
        return Appointment::findOrFail($id);
    }

    // Se crea una nueva cita
    public function create($data)
    {
        return Appointment::create($data);
    }

    // Se actualiza una cita
    public function update(int $id, array $data): ?Appointment
    {
        $appointment = Appointment::findOrFail($id);
        $appointment->update($data);
        return $appointment;
    }

    // Se elimina una cita
    public function delete(int $id)
    {
        Appointment::destroy($id);
    }

    // Se busca si existe una cita en conflicto (mismo horario, misma fecha, mismo schedule)
    public function findConflict(
        int $idSchedule,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null
    ): ?Appointment {
        $query = Appointment::where('id_schedule', $idSchedule)
            ->where('date', $date)
            ->where('start_time', $startTime)
            ->where('status', 'accepted');

        if ($ignoreAppointmentId !== null) {
            $query->where('id', '!=', $ignoreAppointmentId);
        }

        return $query->first();
    }
}
