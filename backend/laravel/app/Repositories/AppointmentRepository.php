<?php

namespace App\Repositories;

use App\Models\Appointment;
use Illuminate\Support\Facades\DB;

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
        $appointment = Appointment::findOrFail($id);
        $appointment->delete();
    }

    // Se busca si existe una cita en una hora, fecha y schedule
    public function findAppointment(
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

    // Retorna datos para mandar notificación
    public function findNotificationContext(int $appointmentId)
    {
        return DB::table('appointments')
            ->join('schedules', 'schedules.id', '=', 'appointments.id_schedule')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->join('users as doctor', 'doctor.id', '=', 'schedules.id_doctor')
            ->where('appointments.id', $appointmentId)
            ->select([
                'appointments.id',
                'appointments.id_patient',
                'appointments.name_patient as patient_name',
                'appointments.date',
                'appointments.start_time',
                'doctor.name as doctor_name',
                'clinics.id_client as client_id',
            ])
            ->first();
    }

    // Retorna las secretarias activas de un cliente
    public function findSecretariesByClient(int $clientId)
    {
        return DB::table('users')
            ->join('client_users', 'client_users.id_user', '=', 'users.id')
            ->where('client_users.id_client', $clientId)
            ->where('client_users.role', 2)
            ->where('client_users.is_active', true)
            ->where('users.is_active', true)
            ->select([
                'users.id',
                'users.name',
                'users.email',
                'users.fcm_token',
            ])
            ->get();
    }
}
