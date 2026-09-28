<?php

namespace App\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Repositories\ScheduleRepository;
use Carbon\CarbonImmutable;

class AppointmentAvailabilityService
{
    public function __construct(
        private AppointmentRepository $appointmentRepository,
        private ScheduleBlockadeRepository $blockadeRepository,
        private ScheduleRepository $scheduleRepository,
        private string $timezone = 'America/Guatemala',
    ) {}

    public function ensureAvailable(
        int $scheduleId,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null,
        ?int $patientId = null,
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

        $appointments = $this->appointmentRepository->findActiveByDoctorAndDate(
            (int) $schedule->id_doctor,
            $date,
            $ignoreAppointmentId,
        );

        foreach ($appointments as $appointment) {
            $appointmentStart = $this->timeToMinutes($appointment->start_time);
            $appointmentEnd = $appointmentStart + (int) $appointment->duration;

            if ($this->overlaps($start, $end, $appointmentStart, $appointmentEnd)) {
                throw new AppointmentUnavailableException(
                    AppointmentUnavailableException::OCCUPIED
                );
            }
        }

        if ($patientId === null) {
            return;
        }

        $patientAppointments = $this->appointmentRepository
            ->findActiveByPatientAndDate($patientId, $date, $ignoreAppointmentId);

        foreach ($patientAppointments as $appointment) {
            $appointmentStart = $this->timeToMinutes($appointment->start_time);
            $appointmentEnd = $appointmentStart + (int) $appointment->duration;

            if ($this->overlaps($start, $end, $appointmentStart, $appointmentEnd)) {
                throw new AppointmentUnavailableException(
                    AppointmentUnavailableException::OCCUPIED
                );
            }
        }
    }

    public function resolveReschedule(
        object $appointment,
        string $date,
        string $startTime,
    ): object {
        if (! in_array($appointment->status, [
            'accepted',
            'requested',
            'backup_pending',
            'backup_accepted',
        ], true)) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::NOT_ACTIVE
            );
        }

        $requested = CarbonImmutable::createFromFormat(
            'Y-m-d H:i',
            $date.' '.substr($startTime, 0, 5),
            $this->timezone,
        );

        if ($requested === false) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::PAST
            );
        }

        $requested = $requested->startOfMinute();
        $now = CarbonImmutable::now($this->timezone)->startOfMinute();

        if ($requested->lt($now)) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::PAST
            );
        }

        if (
            (string) $appointment->date === $date
            && substr((string) $appointment->start_time, 0, 5)
                === substr($startTime, 0, 5)
        ) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::UNCHANGED
            );
        }

        $currentSchedule = $this->scheduleRepository->findById(
            $appointment->id_schedule
        );
        $dayOfWeek = $requested->dayOfWeekIso - 1;
        $schedules = $this->scheduleRepository->findActiveByDoctorClinicAndDay(
            (int) $currentSchedule->id_doctor,
            (int) $currentSchedule->id_clinic,
            $dayOfWeek,
        );

        foreach ($schedules as $schedule) {
            if (! $this->fitsSchedule($schedule, $startTime)) {
                continue;
            }

            $this->ensureAvailable(
                (int) $schedule->id,
                $date,
                $startTime,
                (int) $appointment->id,
                $appointment->id_patient === null
                    ? null
                    : (int) $appointment->id_patient,
            );

            return $schedule;
        }

        throw new AppointmentUnavailableException(
            AppointmentUnavailableException::INVALID_SCHEDULE
        );
    }

    public function resolveAlternative(
        object $targetAppointment,
        string $date,
        string $startTime,
        ?int $patientId = null,
    ): object {
        $requested = CarbonImmutable::createFromFormat(
            'Y-m-d H:i',
            $date.' '.substr($startTime, 0, 5),
            $this->timezone,
        );

        if ($requested === false) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::PAST
            );
        }

        $requested = $requested->startOfMinute();
        $now = CarbonImmutable::now($this->timezone)->startOfMinute();
        if ($requested->lt($now)) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::PAST
            );
        }

        if (
            (string) $targetAppointment->date === $date
            && substr((string) $targetAppointment->start_time, 0, 5)
                === substr($startTime, 0, 5)
        ) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::UNCHANGED
            );
        }

        $targetSchedule = $this->scheduleRepository->findById(
            $targetAppointment->id_schedule
        );
        $dayOfWeek = $requested->dayOfWeekIso - 1;
        $schedules = $this->scheduleRepository->findActiveByDoctorClinicAndDay(
            (int) $targetSchedule->id_doctor,
            (int) $targetSchedule->id_clinic,
            $dayOfWeek,
        );

        foreach ($schedules as $schedule) {
            if (! $this->fitsSchedule($schedule, $startTime)) {
                continue;
            }

            $this->scheduleRepository->lockById((int) $schedule->id);
            $this->ensureAvailable(
                (int) $schedule->id,
                $date,
                $startTime,
                null,
                $patientId,
            );

            return $schedule;
        }

        throw new AppointmentUnavailableException(
            AppointmentUnavailableException::INVALID_SCHEDULE
        );
    }

    private function fitsSchedule(object $schedule, string $startTime): bool
    {
        $start = $this->timeToMinutes($startTime);
        $scheduleStart = $this->timeToMinutes($schedule->start_time);
        $scheduleEnd = $this->timeToMinutes($schedule->end_time);
        $duration = (int) $schedule->duration;

        return $start >= $scheduleStart
            && $start + $duration <= $scheduleEnd
            && ($start - $scheduleStart) % $duration === 0;
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
