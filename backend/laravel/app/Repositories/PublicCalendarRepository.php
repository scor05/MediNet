<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class PublicCalendarRepository
{
    public function getPublicCalendar(array $filters)
    {
        $query = DB::table('appointments')
            ->join('schedules', 'appointments.id_schedule', '=', 'schedules.id')
            ->join('clinics', 'schedules.id_clinic', '=', 'clinics.id')
            ->join('users as doctors', 'schedules.id_doctor', '=', 'doctors.id')
            ->select(
                'appointments.id as appointment_id',
                'clinics.id as clinic_id',
                'clinics.name as clinic_name',
                'doctors.id as doctor_id',
                'doctors.name as doctor_name',
                'appointments.date',
                'appointments.start_time',
                'schedules.duration'
            )
            ->orderBy('appointments.date')
            ->orderBy('appointments.start_time');

        if (isset($filters['doctor_id'])) {
            $query->where('schedules.id_doctor', $filters['doctor_id']);
        }

        if (isset($filters['clinic_id'])) {
            $query->where('schedules.id_clinic', $filters['clinic_id']);
        }

        if (isset($filters['date_from'])) {
            $query->whereDate('appointments.date', '>=', $filters['date_from']);
        }

        if (isset($filters['date_to'])) {
            $query->whereDate('appointments.date', '<=', $filters['date_to']);
        }

        return $query->get();
    }
}