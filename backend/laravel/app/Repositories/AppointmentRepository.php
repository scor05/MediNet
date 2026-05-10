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

    // Se obtienen las citas solicitadas de doctores asociados al cliente de una secretaria
    public function findPendingForSecretary(int $clientId): array
    {
        return DB::table('appointments AS a')
            ->join('schedules AS s', 's.id', '=', 'a.id_schedule')
            ->join('clinics AS cl', 'cl.id', '=', 's.id_clinic')
            ->join('users AS doctor', 'doctor.id', '=', 's.id_doctor')
            ->leftJoin('users AS patient', 'patient.id', '=', 'a.id_patient')
            ->join('client_users AS cu', function ($join) use ($clientId) {
                $join->on('cu.id_user', '=', 's.id_doctor')
                    ->where('cu.id_client', '=', $clientId)
                    ->where('cu.role', '=', 1)
                    ->where('cu.is_active', '=', true);
            })
            ->where('a.status', 'requested')
            ->select([
                'a.id',
                'a.id_schedule',
                'a.id_patient',
                'a.date',
                'a.start_time',
                'a.status',
                'doctor.id    AS doctor_id',
                'doctor.name  AS doctor_name',
                'cl.id        AS clinic_id',
                'cl.name      AS clinic_name',
                DB::raw('COALESCE(patient.name, a.name_patient) AS patient_name'),
            ])
            ->orderBy('a.date')
            ->orderBy('a.start_time')
            ->get()
            ->toArray();
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
}
