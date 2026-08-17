<?php

namespace App\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Repositories\ScheduleRepository;

class AppointmentAvailabilityService
{
    public function __construct(
        private AppointmentRepository $appointmentRepository,
        private ScheduleBlockadeRepository $blockadeRepository,
        private ScheduleRepository $scheduleRepository,
    ) {}

    public function ensureAvailable(
        int $scheduleId,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null,
    ): void {
        $schedule = $this->scheduleRepository->findById($scheduleId);
        $start = $this->timeToMinutes($startTime);
        $end = $start + (int) $schedule->duration;

        $blockades = $this->blockadeRepository->findByScheduleAndDate($scheduleId, $date);

        foreach ($blockades as $blockade) {
            if ($this->overlaps(
                $start,
                $end,
                $this->timeToMinutes($blockade->start_time),
                $this->timeToMinutes($blockade->end_time),
            )) {
                throw new AppointmentUnavailableException(
                    AppointmentUnavailableException::BLOCKED
                );
            }
        }

        $appointments = $this->appointmentRepository->findActiveByScheduleAndDate(
            $scheduleId,
            $date,
            $ignoreAppointmentId,
        );

        foreach ($appointments as $appointment) {
            $appointmentStart = $this->timeToMinutes($appointment->start_time);
            $appointmentEnd = $appointmentStart + (int) $schedule->duration;

            if ($this->overlaps($start, $end, $appointmentStart, $appointmentEnd)) {
                throw new AppointmentUnavailableException(
                    AppointmentUnavailableException::OCCUPIED
                );
            }
        }
    }

    private function overlaps(int $start, int $end, int $otherStart, int $otherEnd): bool
    {
        return $start < $otherEnd && $end > $otherStart;
    }

    private function timeToMinutes(string $time): int
    {
        [$hour, $minute] = array_map('intval', explode(':', substr($time, 0, 5)));

        return ($hour * 60) + $minute;
    }
}
