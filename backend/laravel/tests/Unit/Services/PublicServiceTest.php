<?php

namespace Tests\Unit\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Repositories\AppointmentRepository;
use App\Repositories\PublicRepository;
use App\Services\AppointmentAvailabilityService;
use App\Services\NotificationService;
use App\Services\PublicService;
use PHPUnit\Framework\TestCase;

class PublicServiceTest extends TestCase
{
    public function test_public_request_is_not_created_when_the_slot_is_blocked(): void
    {
        $repository = $this->createMock(PublicRepository::class);
        $appointmentRepository = $this->createStub(AppointmentRepository::class);
        $notificationService = $this->createStub(NotificationService::class);
        $availabilityService = $this->createMock(AppointmentAvailabilityService::class);

        $availabilityService->method('ensureAvailable')
            ->willThrowException(new AppointmentUnavailableException(
                AppointmentUnavailableException::BLOCKED
            ));
        $repository->expects($this->never())->method('createAppointment');

        $service = new PublicService(
            $repository,
            $appointmentRepository,
            $notificationService,
            $availabilityService,
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(AppointmentUnavailableException::BLOCKED);

        $service->createAppointment([
            'id_schedule' => 4,
            'id_patient' => 9,
            'name_patient' => 'Paciente',
            'date' => '2026-08-10',
            'start_time' => '09:00',
        ]);
    }
}
