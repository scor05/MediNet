<?php

namespace App\Repositories;

use App\Models\Waitlist;
use Illuminate\Support\Facades\DB;

class WaitlistRepository
{
    // Se obtienen todos los registros de lista de espera
    public function findAll()
    {
        return Waitlist::all();
    }

    // Se obtiene un registro por su id
    public function findById(int $id)
    {
        return Waitlist::findOrFail($id);
    }

    // Se obtienen los registros de un paciente
    public function findByPatient(int $patientId)
    {
        return Waitlist::where('id_patient', $patientId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    // Se obtienen los waitlists activos vinculados a una cita target
    public function findActiveByTargetAppointment(int $appointmentId)
    {
        return Waitlist::where('id_target_appointment', $appointmentId)
            ->where('status', 'active')
            ->get();
    }

    // Se crea un nuevo registro
    public function create(array $data)
    {
        return Waitlist::create($data);
    }

    // Se actualiza un registro
    public function update(int $id, array $data)
    {
        $waitlist = Waitlist::findOrFail($id);
        $waitlist->update($data);
        return $waitlist;
    }

    // Se elimina un registro
    public function delete(int $id)
    {
        $waitlist = Waitlist::findOrFail($id);
        $waitlist->delete();
    }

    // Retorna datos contextuales para construir el mensaje de notificación
    public function findNotificationContext(int $waitlistId)
    {
        return DB::table('waitlists')
            ->join('appointments', 'appointments.id', '=', 'waitlists.id_target_appointment')
            ->join('schedules', 'schedules.id', '=', 'appointments.id_schedule')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->join('users as doctor', 'doctor.id', '=', 'schedules.id_doctor')
            ->where('waitlists.id', $waitlistId)
            ->select([
                'waitlists.id as waitlist_id',
                'waitlists.id_patient',
                'appointments.date',
                'appointments.start_time',
                'doctor.name as doctor_name',
                'clinics.name as clinic_name',
            ])
            ->first();
    }
}
