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

    public function findByIdForUpdate(int $id): Appointment
    {
        return Appointment::whereKey($id)->lockForUpdate()->firstOrFail();
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

    // Se buscan citas que todavía reservan o solicitan un espacio del horario
    public function findActiveByScheduleAndDate(
        int $idSchedule,
        string $date,
        ?int $ignoreAppointmentId = null
    ) {
        $query = Appointment::where('id_schedule', $idSchedule)
            ->where('date', $date)
            ->whereIn('status', [
                'requested',
                'accepted',
                'rescheduled',
                'backup_pending',
                'backup_accepted',
            ]);

        if ($ignoreAppointmentId !== null) {
            $query->where('id', '!=', $ignoreAppointmentId);
        }

        return $query->get();
    }

    public function findActiveByDoctorAndDate(
        int $doctorId,
        string $date,
        ?int $ignoreAppointmentId = null,
    ) {
        $query = Appointment::query()
            ->join('schedules', 'schedules.id', '=', 'appointments.id_schedule')
            ->where('schedules.id_doctor', $doctorId)
            ->where('appointments.date', $date)
            ->whereIn('appointments.status', [
                'requested', 'accepted', 'rescheduled',
                'backup_pending', 'backup_accepted',
            ])
            ->select([
                'appointments.id',
                'appointments.start_time',
                'schedules.duration',
            ]);

        if ($ignoreAppointmentId !== null) {
            $query->where('appointments.id', '!=', $ignoreAppointmentId);
        }

        return $query->get();
    }

    public function findActiveByPatientAndDate(
        int $patientId,
        string $date,
        ?int $ignoreAppointmentId = null,
    ) {
        $query = Appointment::query()
            ->join('schedules', 'schedules.id', '=', 'appointments.id_schedule')
            ->where('appointments.id_patient', $patientId)
            ->where('appointments.date', $date)
            ->whereIn('appointments.status', [
                'requested', 'accepted', 'rescheduled',
                'backup_pending', 'backup_accepted',
            ])
            ->select([
                'appointments.id',
                'appointments.start_time',
                'schedules.duration',
            ]);

        if ($ignoreAppointmentId !== null) {
            $query->where('appointments.id', '!=', $ignoreAppointmentId);
        }

        return $query->get();
    }

    public function findOccupyingSlot(int $scheduleId, string $date, string $startTime): ?Appointment
    {
        return Appointment::where('id_schedule', $scheduleId)
            ->where('date', $date)
            ->where('start_time', $startTime)
            ->whereIn('status', [
                'requested',
                'accepted',
                'rescheduled',
                'backup_pending',
                'backup_accepted',
            ])
            ->orderBy('created_at')
            ->orderBy('id')
            ->first();
    }

    public function canDecide(int $appointmentId, int $actorId): bool
    {
        return DB::table('appointments AS a')
            ->join('schedules AS s', 's.id', '=', 'a.id_schedule')
            ->join('clinics AS c', 'c.id', '=', 's.id_clinic')
            ->where('a.id', $appointmentId)
            ->where(function ($query) use ($actorId) {
                $query->where('s.id_doctor', $actorId)
                    ->orWhereExists(function ($subquery) use ($actorId) {
                        $subquery->selectRaw('1')
                            ->from('client_users AS cu')
                            ->whereColumn('cu.id_client', 'c.id_client')
                            ->where('cu.id_user', $actorId)
                            ->where('cu.role', 2)
                            ->where('cu.is_active', true);
                    });
            })
            ->exists();
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
                'doctor.id as doctor_id',
                'doctor.name as doctor_name',
                'clinics.name as clinic_name',
                'clinics.id_client as client_id',
            ])
            ->first();
    }

    public function findRealtimeAudienceBySchedule(int $scheduleId): ?object
    {
        return DB::table('schedules')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->where('schedules.id', $scheduleId)
            ->select([
                'schedules.id_doctor as doctor_id',
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
