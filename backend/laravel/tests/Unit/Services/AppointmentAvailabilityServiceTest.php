<?php

namespace Tests\Unit\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Repositories\ScheduleRepository;
use App\Services\AppointmentAvailabilityService;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;
use PHPUnit\Framework\TestCase;

class AppointmentAvailabilityServiceTest extends TestCase
{
    protected function tearDown(): void
    {
        CarbonImmutable::setTestNow();
        parent::tearDown();
    }

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

    public function test_reschedule_rejects_a_past_time(): void
    {
        CarbonImmutable::setTestNow('2026-09-03 10:30:00 America/Guatemala');
        $appointmentRepository = $this->createStub(AppointmentRepository::class);
        $blockadeRepository = $this->createStub(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createStub(ScheduleRepository::class);
        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(AppointmentUnavailableException::PAST);

        $service->resolveReschedule(
            (object) [
                'id' => 8,
                'id_schedule' => 4,
                'date' => '2026-09-04',
                'start_time' => '09:00:00',
                'status' => 'accepted',
            ],
            '2026-09-03',
            '10:29',
        );
    }

    public function test_reschedule_rejects_a_cancelled_appointment(): void
    {
        $appointmentRepository = $this->createStub(AppointmentRepository::class);
        $blockadeRepository = $this->createStub(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createStub(ScheduleRepository::class);
        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(
            AppointmentUnavailableException::NOT_ACTIVE
        );

        $service->resolveReschedule(
            (object) [
                'id' => 8,
                'id_schedule' => 4,
                'date' => '2026-09-04',
                'start_time' => '09:00:00',
                'status' => 'cancelled',
            ],
            '2026-09-05',
            '10:00',
        );
    }

    public function test_reschedule_rejects_a_time_without_an_active_schedule(): void
    {
        CarbonImmutable::setTestNow('2026-09-03 10:30:00 America/Guatemala');
        $appointmentRepository = $this->createStub(AppointmentRepository::class);
        $blockadeRepository = $this->createStub(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createMock(ScheduleRepository::class);
        $scheduleRepository->method('findById')->willReturn((object) [
            'id_doctor' => 3,
            'id_clinic' => 2,
        ]);
        $scheduleRepository->expects($this->once())
            ->method('findActiveByDoctorClinicAndDay')
            ->with(3, 2, 4)
            ->willReturn(new Collection);
        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(
            AppointmentUnavailableException::INVALID_SCHEDULE
        );

        $service->resolveReschedule(
            (object) [
                'id' => 8,
                'id_schedule' => 4,
                'date' => '2026-09-04',
                'start_time' => '09:00:00',
                'status' => 'accepted',
            ],
            '2026-09-04',
            '10:00',
        );
    }

    public function test_reschedule_resolves_a_valid_free_schedule(): void
    {
        CarbonImmutable::setTestNow('2026-09-03 10:30:00 America/Guatemala');
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $blockadeRepository = $this->createMock(ScheduleBlockadeRepository::class);
        $scheduleRepository = $this->createMock(ScheduleRepository::class);
        $schedule = (object) [
            'id' => 9,
            'start_time' => '09:00:00',
            'end_time' => '12:00:00',
            'duration' => 30,
        ];
        $scheduleRepository->method('findById')->willReturnCallback(
            fn (int $id) => $id === 9
                ? $schedule
                : (object) ['id_doctor' => 3, 'id_clinic' => 2]
        );
        $scheduleRepository->method('findActiveByDoctorClinicAndDay')
            ->willReturn(new Collection([$schedule]));
        $blockadeRepository->expects($this->once())
            ->method('findByScheduleAndDate')
            ->with(9, '2026-09-04')
            ->willReturn(new Collection);
        $appointmentRepository->expects($this->once())
            ->method('findActiveByScheduleAndDate')
            ->with(9, '2026-09-04', 8)
            ->willReturn(new Collection);
        $service = new AppointmentAvailabilityService(
            $appointmentRepository,
            $blockadeRepository,
            $scheduleRepository,
        );

        $resolved = $service->resolveReschedule(
            (object) [
                'id' => 8,
                'id_schedule' => 4,
                'date' => '2026-09-03',
                'start_time' => '11:00:00',
                'status' => 'accepted',
            ],
            '2026-09-04',
            '10:00',
        );

        $this->assertSame($schedule, $resolved);
    }
}
