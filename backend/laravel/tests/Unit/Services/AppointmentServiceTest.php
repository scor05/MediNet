<?php

namespace Tests\Unit\Services;

use App\Models\Appointment;
use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Services\AppointmentService;
use App\Services\NotificationService;
use App\Services\UserService;
use PHPUnit\Framework\TestCase;

class AppointmentServiceTest extends TestCase
{
    public function test_create_uses_the_registered_patients_name_and_persists_the_appointment(): void
    {
        $repository = $this->createMock(AppointmentRepository::class);
        $userService = $this->createMock(UserService::class);
        $blockadeRepository = $this->createMock(ScheduleBlockadeRepository::class);
        $notificationService = $this->createStub(NotificationService::class);

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

        $repository->expects($this->once())
            ->method('findAppointment')
            ->with(11, '2026-07-21', '09:00', null)
            ->willReturn(null);

        $blockadeRepository->expects($this->once())
            ->method('findBlockadeAtTime')
            ->with(11, '2026-07-21', '09:00')
            ->willReturn(null);

        $userService->expects($this->once())
            ->method('getById')
            ->with(7)
            ->willReturn((object) ['name' => 'Ana Lopez']);

        $createdAppointment = new Appointment;
        $repository->expects($this->once())
            ->method('create')
            ->with($this->callback(
                fn (array $appointment) => $appointment['name_patient'] === 'Ana Lopez'
                    && $appointment['id_patient'] === 7
            ))
            ->willReturn($createdAppointment);

        $service = new AppointmentService(
            $repository,
            $userService,
            $blockadeRepository,
            $notificationService,
        );

        $this->assertSame($createdAppointment, $service->create($data));
    }
}
