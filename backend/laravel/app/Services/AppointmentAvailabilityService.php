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

    // Reglas de dominio para crear una cita nueva: fecha futura, horario, clínica y
    // médico activos, día y rango del horario, alineación con la duración y ausencia
    // de bloqueos o solapamientos.
    public function ensureBookable(
        int $scheduleId,
        string $date,
        string $startTime,
        ?int $patientId = null,
    ): void {
        $requested = $this->parseDateTime($date, $startTime);

        if ($requested->lt(CarbonImmutable::now($this->timezone)->startOfMinute())) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::PAST_BOOKING
            );
        }

        $schedule = $this->scheduleRepository->findBookingContext($scheduleId);

        if ($schedule === null || ! (bool) $schedule->is_active) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::INACTIVE_SCHEDULE
            );
        }

        if (! (bool) $schedule->clinic_is_active) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::INACTIVE_CLINIC
            );
        }

        if (! $this->scheduleRepository->isDoctorActiveInClient(
            (int) $schedule->id_doctor,
            (int) $schedule->clinic_id_client,
        )) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::INACTIVE_DOCTOR
            );
        }

        if ((int) $schedule->day_of_week !== $requested->dayOfWeekIso - 1) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::WRONG_DAY
            );
        }

        if (! $this->isWithinRange($schedule, $startTime)) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::OUTSIDE_RANGE
            );
        }

        if (! $this->isAligned($schedule, $startTime)) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::MISALIGNED
            );
        }

        $this->ensureAvailable($scheduleId, $date, $startTime, null, $patientId);
    }

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
        return $this->isWithinRange($schedule, $startTime)
            && $this->isAligned($schedule, $startTime);
    }

    // La cita completa (inicio + duración) debe quedar dentro del horario
    private function isWithinRange(object $schedule, string $startTime): bool
    {
        $start = $this->timeToMinutes($startTime);

        return $start >= $this->timeToMinutes($schedule->start_time)
            && $start + (int) $schedule->duration <= $this->timeToMinutes($schedule->end_time);
    }

    // La cita debe empezar en un múltiplo de la duración desde el inicio del horario
    private function isAligned(object $schedule, string $startTime): bool
    {
        $duration = (int) $schedule->duration;
        $offset = $this->timeToMinutes($startTime) - $this->timeToMinutes($schedule->start_time);

        return $duration > 0 && $offset % $duration === 0;
    }

    private function parseDateTime(string $date, string $startTime): CarbonImmutable
    {
        $value = $date.' '.substr($startTime, 0, 5);
        $requested = CarbonImmutable::createFromFormat('Y-m-d H:i', $value, $this->timezone);

        // createFromFormat acepta fechas desbordadas como 2026-02-31; se exige que
        // el valor interpretado coincida exactamente con el recibido.
        if ($requested === false || $requested->format('Y-m-d H:i') !== $value) {
            throw new AppointmentUnavailableException(
                AppointmentUnavailableException::INVALID_DATE
            );
        }

        return $requested->startOfMinute();
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
