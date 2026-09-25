<?php

namespace App\Repositories;

use App\Models\Schedule;
use Illuminate\Support\Facades\DB;

class ScheduleRepository
{
    // Se obtienen los horarios de un doctor
    public function findByDoctor($doctorId)
    {
        return Schedule::select('schedules.*', 'clinics.name as clinic_name')
            ->join('clinics', 'schedules.id_clinic', '=', 'clinics.id')
            ->where('schedules.id_doctor', $doctorId)
            ->where('schedules.is_active', true)
            ->where('clinics.is_active', true)
            ->get();
    }

    public function findForSecretary(int $secretaryId)
    {
        return Schedule::query()
            ->select([
                'schedules.*',
                'clinics.name as clinic_name',
                'users.name as doctor_name',
            ])
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->join('users', 'users.id', '=', 'schedules.id_doctor')
            ->join('client_users as doctor_membership', function ($join) {
                $join->on('doctor_membership.id_user', '=', 'schedules.id_doctor')
                    ->on('doctor_membership.id_client', '=', 'clinics.id_client')
                    ->where('doctor_membership.role', 1)
                    ->where('doctor_membership.is_active', true);
            })
            ->join('client_users as secretary_membership', function ($join) use ($secretaryId) {
                $join->on('secretary_membership.id_client', '=', 'doctor_membership.id_client')
                    ->where('secretary_membership.id_user', $secretaryId)
                    ->where('secretary_membership.role', 2)
                    ->where('secretary_membership.is_active', true);
            })
            ->where('schedules.is_active', true)
            ->where('clinics.is_active', true)
            ->where('users.is_active', true)
            ->distinct()
            ->orderBy('schedules.day_of_week')
            ->orderBy('schedules.start_time')
            ->get();
    }

    // Se obtiene un horario por su ID
    public function findById($id)
    {
        return Schedule::findOrFail($id);
    }

    public function findActiveByDoctorClinicAndDay(
        int $doctorId,
        int $clinicId,
        int $dayOfWeek,
    ) {
        return Schedule::where('id_doctor', $doctorId)
            ->where('id_clinic', $clinicId)
            ->where('day_of_week', $dayOfWeek)
            ->where('is_active', true)
            ->orderBy('start_time')
            ->get();
    }

    // Se crea un nuevo horario
    public function create($data)
    {
        return Schedule::create($data);
    }

    public function canCreateForDoctorAtClinic(
        int $actorId,
        int $doctorId,
        int $clinicId,
    ): bool {
        $clientId = DB::table('clinics')
            ->where('id', $clinicId)
            ->where('is_active', true)
            ->value('id_client');

        if ($clientId === null) {
            return false;
        }

        $doctorBelongsToClient = DB::table('client_users')
            ->where('id_user', $doctorId)
            ->where('id_client', $clientId)
            ->where('role', 1)
            ->where('is_active', true)
            ->exists();

        if (! $doctorBelongsToClient) {
            return false;
        }

        if ($actorId === $doctorId) {
            return true;
        }

        return DB::table('client_users')
            ->where('id_user', $actorId)
            ->where('id_client', $clientId)
            ->where('role', 2)
            ->where('is_active', true)
            ->exists();
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

    public function deactivate($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->update(['is_active' => false]);
    }

    // Se verifica si el doctor ya tiene un horario en ese día y hora
    public function findOverlappingSchedule($doctorId, $dayOfWeek, $startTime, $endTime, $excludeId = null)
    {
        return Schedule::where('id_doctor', $doctorId)
            ->where('day_of_week', $dayOfWeek)
            ->where('is_active', true)
            ->when($excludeId, fn ($q) => $q->where('id', '!=', $excludeId))
            ->where(function ($query) use ($startTime, $endTime) {
                $query->where('start_time', '<', $endTime)
                    ->where('end_time', '>', $startTime);
            })
            ->exists();
    }
}
