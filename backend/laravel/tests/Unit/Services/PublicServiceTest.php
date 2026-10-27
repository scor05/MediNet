<?php

namespace Tests\Unit\Services;

use App\Exceptions\AppointmentUnavailableException;
use App\Models\User;
use App\Repositories\AppointmentRepository;
use App\Repositories\PublicRepository;
use App\Services\AppointmentAvailabilityService;
use App\Services\AppointmentBookingLockService;
use App\Services\AppointmentRealtimeService;
use App\Services\NotificationService;
use App\Services\PublicService;
use Tests\TestCase;

class PublicServiceTest extends TestCase
{
    public function test_public_request_is_not_created_when_the_slot_is_blocked(): void
    {
        $repository = $this->createMock(PublicRepository::class);
        $appointmentRepository = $this->createStub(AppointmentRepository::class);
        $notificationService = $this->createStub(NotificationService::class);
        $availabilityService = $this->createMock(AppointmentAvailabilityService::class);
        $bookingLockService = $this->createMock(AppointmentBookingLockService::class);

        $bookingLockService->expects($this->once())
            ->method('acquire')
            ->with(4, '2026-08-10', 9);

        $availabilityService->expects($this->once())
            ->method('ensureBookable')
            ->with(4, '2026-08-10', '09:00', 9)
            ->willThrowException(new AppointmentUnavailableException(
                AppointmentUnavailableException::BLOCKED
            ));
        $repository->expects($this->never())->method('createAppointment');

        $service = new PublicService(
            $repository,
            $appointmentRepository,
            $notificationService,
            $availabilityService,
            $bookingLockService,
            $this->createStub(AppointmentRealtimeService::class),
        );

        $this->expectException(AppointmentUnavailableException::class);
        $this->expectExceptionMessage(AppointmentUnavailableException::BLOCKED);

        $patient = new User;
        $patient->id = 9;
        $patient->name = 'Paciente';

        $service->createAppointment([
            'id_schedule' => 4,
            'id_patient' => 999,
            'name_patient' => 'Paciente Suplantado',
            'created_by' => 999,
            'updated_by' => 999,
            'date' => '2026-08-10',
            'start_time' => '09:00',
        ], $patient);
    }
}
