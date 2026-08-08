<?php

namespace Tests\Unit\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Repositories\ScheduleRepository;
use App\Services\AppointmentAvailabilityService;
use Illuminate\Support\Collection;
use PHPUnit\Framework\TestCase;

class AppointmentAvailabilityServiceTest extends TestCase
{
    public function test_it_rejects_an_appointment_that_overlaps_a_blockade(): void
    {
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $blockadeRepository = $this->createMock(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createMock(ScheduleRepository::class);

        $scheduleRepository->method('findById')->willReturn((object) ['duration' => 30]);
        $blockadeRepository->method('findByScheduleAndDate')->willReturn(new Collection([
            (object) ['start_time' => '09:15:00', 'end_time' => '10:00:00'],
        ]));
        $appointmentRepository->expects($this->never())
            ->method('findActiveByScheduleAndDate');

        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(AppointmentUnavailableException::BLOCKED);

        $service->ensureAvailable(4, '2026-08-10', '09:00');
    }

    public function test_it_rejects_an_appointment_that_overlaps_an_active_request(): void
    {
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $blockadeRepository = $this->createMock(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createMock(ScheduleRepository::class);

        $scheduleRepository->method('findById')->willReturn((object) ['duration' => 30]);
        $blockadeRepository->method('findByScheduleAndDate')->willReturn(new Collection);
        $appointmentRepository->method('findActiveByScheduleAndDate')->willReturn(new Collection([
            (object) ['start_time' => '09:15:00'],
        ]));

        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(AppointmentUnavailableException::OCCUPIED);

        $service->ensureAvailable(4, '2026-08-10', '09:00');
    }

    public function test_it_accepts_adjacent_non_overlapping_intervals(): void
    {
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $blockadeRepository = $this->createMock(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createMock(ScheduleRepository::class);

        $scheduleRepository->method('findById')->willReturn((object) ['duration' => 30]);
        $blockadeRepository->method('findByScheduleAndDate')->willReturn(new Collection([
            (object) ['start_time' => '08:30:00', 'end_time' => '09:00:00'],
        ]));
        $appointmentRepository->method('findActiveByScheduleAndDate')->willReturn(new Collection([
            (object) ['start_time' => '09:30:00'],
        ]));

        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $service->ensureAvailable(4, '2026-08-10', '09:00');

        $this->addToAssertionCount(1);
    }
}
