<?php

namespace App\Repositories;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PublicRepository
{
    // Se obtienen los doctores con horarios activos
    public function findDoctors(?int $clinicId)
    {
        return DB::table('users')
            ->join('client_users', 'client_users.id_user', '=', 'users.id')
            ->join('schedules', 'schedules.id_doctor', '=', 'users.id')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->where('users.is_active', true)
            ->where('client_users.role', 1)
            ->where('client_users.is_active', true)
            ->where('schedules.is_active', true)
            ->where('clinics.is_active', true)
            ->when($clinicId, fn($query) => $query->where('clinics.id', $clinicId))
            ->select([
                'users.id',
                'users.name',
                'users.email',
                DB::raw("COALESCE(users.phone, '') AS phone"),
                'users.is_active',
                'users.created_at',
                'users.updated_at',
            ])
            ->distinct()
            ->orderBy('users.name')
            ->get();
    }

    // Se obtienen las clínicas con horarios activos
    public function findClinics(?int $doctorId)
    {
        return DB::table('clinics')
            ->join('schedules', 'schedules.id_clinic', '=', 'clinics.id')
            ->join('users', 'users.id', '=', 'schedules.id_doctor')
            ->where('clinics.is_active', true)
            ->where('schedules.is_active', true)
            ->where('users.is_active', true)
            ->when($doctorId, fn($query) => $query->where('users.id', $doctorId))
            ->select([
                'clinics.id',
                'clinics.name',
                'clinics.address',
                'clinics.phone',
                'clinics.email',
                'clinics.is_active',
                'clinics.created_at',
                'clinics.updated_at',
            ])
            ->distinct()
            ->orderBy('clinics.name')
            ->get();
    }

    // Se obtienen los slots disponibles por doctor, clínica y fecha
    public function findSlots(int $doctorId, int $clinicId, string $date): array
    {
        $dayOfWeek = Carbon::parse($date)->dayOfWeekIso - 1;

        $schedules = DB::table('schedules')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->join('users AS doctor', 'doctor.id', '=', 'schedules.id_doctor')
            ->where('schedules.id_doctor', $doctorId)
            ->where('schedules.id_clinic', $clinicId)
            ->where('schedules.day_of_week', $dayOfWeek)
            ->where('schedules.is_active', true)
            ->where('clinics.is_active', true)
            ->where('doctor.is_active', true)
            ->select([
                'schedules.id',
                'schedules.start_time',
                'schedules.end_time',
                'schedules.duration',
                'doctor.id AS doctor_id',
                'doctor.name AS doctor_name',
                'clinics.id AS clinic_id',
                'clinics.name AS clinic_name',
            ])
            ->orderBy('schedules.start_time')
            ->get();

        if ($schedules->isEmpty()) {
            return [];
        }

        $scheduleIds = $schedules->pluck('id')->all();

        $taken = DB::table('appointments')
            ->whereIn('id_schedule', $scheduleIds)
            ->where('date', $date)
            ->whereNotIn('status', ['rejected', 'cancelled'])
            ->get(['id_schedule', 'start_time'])
            ->mapWithKeys(fn($appointment) => [
                $appointment->id_schedule . '-' . substr($appointment->start_time, 0, 5) => true,
            ]);

        $slots = [];

        foreach ($schedules as $schedule) {
            $start = $this->timeToMinutes($schedule->start_time);
            $end = $this->timeToMinutes($schedule->end_time);

            for ($current = $start; $current + $schedule->duration <= $end; $current += $schedule->duration) {
                $startTime = $this->minutesToTime($current);
                $key = $schedule->id . '-' . $startTime;

                if ($taken->has($key)) {
                    continue;
                }

                $slots[] = [
                    'schedule_id' => $schedule->id,
                    'start_time' => $startTime,
                    'end_time' => $this->minutesToTime($current + $schedule->duration),
                    'doctor' => [
                        'id' => $schedule->doctor_id,
                        'name' => $schedule->doctor_name,
                    ],
                    'clinic' => [
                        'id' => $schedule->clinic_id,
                        'name' => $schedule->clinic_name,
                    ],
                ];
            }
        }

        return $slots;
    }

    private function timeToMinutes(string $time): int
    {
        [$hour, $minute] = array_map('intval', explode(':', substr($time, 0, 5)));
        return ($hour * 60) + $minute;
    }

    private function minutesToTime(int $minutes): string
    {
        $hour = intdiv($minutes, 60);
        $minute = $minutes % 60;
        return str_pad((string) $hour, 2, '0', STR_PAD_LEFT)
            . ':'
            . str_pad((string) $minute, 2, '0', STR_PAD_LEFT);
    }
}
