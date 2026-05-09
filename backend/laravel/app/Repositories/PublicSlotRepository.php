<?php

namespace App\Repositories;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PublicSlotRepository
{
    public function getAvailableSlots(int $doctorId, int $clinicId, string $date): array
    {
        $dayOfWeek = Carbon::parse($date)->dayOfWeek;

        $schedule = DB::table('schedules')
            ->where('id_doctor', $doctorId)
            ->where('id_clinic', $clinicId)
            ->where('day_of_week', $dayOfWeek)
            ->where('is_active', true)
            ->first();

        if (!$schedule) {
            return [
                'id_schedule' => null,
                'slots' => [],
            ];
        }

        $start = Carbon::parse($date . ' ' . $schedule->start_time);
        $end = Carbon::parse($date . ' ' . $schedule->end_time);
        $duration = (int) $schedule->duration;

        $occupiedSlots = DB::table('appointments')
            ->where('id_schedule', $schedule->id)
            ->whereDate('date', $date)
            ->whereIn('status', ['accepted', 'requested'])
            ->pluck('start_time')
            ->map(function ($time) {
                return Carbon::parse($time)->format('H:i:s');
            })
            ->toArray();

        $slots = [];

        $current = $start->copy();

        while ($current->copy()->addMinutes($duration)->lte($end)) {
            $slot = $current->format('H:i:s');

            if (!in_array($slot, $occupiedSlots)) {
                $slots[] = $slot;
            }

            $current->addMinutes($duration);
        }

        return [
            'id_schedule' => $schedule->id,
            'slots' => $slots,
        ];
    }
}