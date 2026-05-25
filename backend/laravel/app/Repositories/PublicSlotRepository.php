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

        // Se obtienen los bloqueos activos del schedule para esa fecha
        $blockades = DB::table('schedule_blockades')
            ->where('id_schedule', $schedule->id)
            ->whereDate('date', $date)
            ->get(['start_time', 'end_time']);

        $slots = [];

        $current = $start->copy();

        while ($current->copy()->addMinutes($duration)->lte($end)) {
            $slot = $current->format('H:i:s');

            // Se verifica que el slot no esté ocupado por una cita
            $isOccupied = in_array($slot, $occupiedSlots);

            // Se verifica que el slot no caiga dentro de algún bloqueo
            $isBlocked = $blockades->contains(function ($blockade) use ($slot) {
                return $slot >= $blockade->start_time && $slot < $blockade->end_time;
            });

            if (!$isOccupied && !$isBlocked) {
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