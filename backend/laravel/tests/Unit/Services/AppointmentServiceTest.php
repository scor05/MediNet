<?php

namespace Tests\Unit\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Models\Appointment;
use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Services\AppointmentAvailabilityService;
use App\Services\AppointmentService;
use App\Services\NotificationService;
use App\Services\UserService;
use App\Services\WaitlistPromotionService;
use PHPUnit\Framework\TestCase;

class AppointmentServiceTest extends TestCase
{
    public function test_create_uses_the_registered_patients_name_and_persists_the_appointment(): void
    {
        $repository = $this->createMock(AppointmentRepository::class);
        $userService = $this->createMock(UserService::class);
        $availabilityService = $this->createMock(AppointmentAvailabilityService::class);
        $blockadeRepository = $this->createStub(ScheduleBlockadeRepository::class);
        $notificationService = $this->createMock(NotificationService::class);
        $waitlistPromotionService = $this->createStub(WaitlistPromotionService::class);

        $data = [
            'id_schedule' => 11,
            'id_patient' => 7,
            'name_patient' => 'Untrusted client value',
            'date' => '2026-07-21',
            'start_time' => '09:00',
            'status' => 'accepted',
            'created_by' => 3,
            'updated_by' => 3,
        ];

        $availabilityService->expects($this->once())
            ->method('ensureAvailable')
            ->with(11, '2026-07-21', '09:00')
            ->willReturnCallback(static function (): void {});

        $userService->expects($this->once())
            ->method('getById')
            ->with(7)
            ->willReturn((object) ['name' => 'Ana Lopez']);

        $createdAppointment = new Appointment;
        $createdAppointment->id = 25;
        $repository->expects($this->once())
            ->method('create')
            ->with($this->callback(
                fn (array $appointment) => $appointment['name_patient'] === 'Ana Lopez'
                    && $appointment['id_patient'] === 7
            ))
            ->willReturn($createdAppointment);
        $repository->expects($this->once())
            ->method('findNotificationContext')
            ->with(25)
            ->willReturn((object) [
                'doctor_name' => 'Carlos Perez',
                'date' => '2026-07-21',
                'start_time' => '09:00:00',
            ]);
        $notificationService->expects($this->once())
            ->method('create')
            ->with($this->callback(
                fn (array $notification) => $notification['id_user'] === 7
                    && $notification['type'] === 'acceptance'
                    && str_contains($notification['message'], 'Dr. Carlos Perez')
                    && str_contains($notification['message'], '21/07/2026')
                    && str_contains($notification['message'], '09:00')
            ));

        $service = new AppointmentService(
            $repository,
            $userService,
            $blockadeRepository,
            $notificationService,
            $waitlistPromotionService,
            $availabilityService,
        );

        $this->assertSame($createdAppointment, $service->create($data));
    }

    public function test_create_does_not_persist_when_the_slot_is_unavailable(): void
    {
        $repository = $this->createMock(AppointmentRepository::class);
        $userService = $this->createMock(UserService::class);
        $availabilityService = $this->createMock(AppointmentAvailabilityService::class);
        $blockadeRepository = $this->createStub(ScheduleBlockadeRepository::class);
        $notificationService = $this->createStub(NotificationService::class);
        $waitlistPromotionService = $this->createStub(WaitlistPromotionService::class);

        $availabilityService->method('ensureAvailable')
            ->willThrowException(new AppointmentUnavailableException(
                AppointmentUnavailableException::BLOCKED
            ));

        $repository->expects($this->never())->method('create');
        $userService->expects($this->never())->method('getById');

        $service = new AppointmentService(
            $repository,
            $userService,
            $blockadeRepository,
            $notificationService,
            $waitlistPromotionService,
            $availabilityService,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(AppointmentUnavailableException::BLOCKED);

        $service->create([
            'id_schedule' => 11,
            'date' => '2026-07-21',
            'start_time' => '09:00',
        ]);
    }

    public function test_create_keeps_a_free_name_without_linking_or_notifying_a_patient(): void
    {
        $repository = $this->createMock(AppointmentRepository::class);
        $userService = $this->createMock(UserService::class);
        $availabilityService = $this->createStub(AppointmentAvailabilityService::class);
        $blockadeRepository = $this->createStub(ScheduleBlockadeRepository::class);
        $notificationService = $this->createMock(NotificationService::class);
        $waitlistPromotionService = $this->createStub(WaitlistPromotionService::class);

        $data = [
            'id_schedule' => 11,
            'id_patient' => null,
            'name_patient' => 'Paciente externo',
            'date' => '2026-07-21',
            'start_time' => '09:00',
            'status' => 'accepted',
        ];
        $createdAppointment = new Appointment;

        $userService->expects($this->never())->method('getById');
        $repository->expects($this->once())
            ->method('create')
            ->with($data)
            ->willReturn($createdAppointment);
        $repository->expects($this->never())->method('findNotificationContext');
        $notificationService->expects($this->never())->method('create');

        $service = new AppointmentService(
            $repository,
            $userService,
            $blockadeRepository,
            $notificationService,
            $waitlistPromotionService,
            $availabilityService,
        );

        $this->assertSame($createdAppointment, $service->create($data));
    }
}
