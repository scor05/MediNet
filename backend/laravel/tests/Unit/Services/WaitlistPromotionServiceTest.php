<?php

namespace Tests\Unit\Services;

use App\Models\Appointment;
use App\Models\Waitlist;
use App\Repositories\AppointmentRepository;
use App\Repositories\WaitlistRepository;
use App\Services\AppointmentAvailabilityService;
use App\Services\NotificationService;
use App\Services\UserService;
use App\Services\WaitlistPromotionService;
use PHPUnit\Framework\TestCase;

class WaitlistPromotionServiceTest extends TestCase
{
    public function test_cancellation_promotes_the_first_waiting_patient_into_the_freed_slot(): void
    {
        $waitlistRepository = $this->createMock(WaitlistRepository::class);
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $userService = $this->createMock(UserService::class);
        $notificationService = $this->createMock(NotificationService::class);
        $availabilityService = $this->createMock(AppointmentAvailabilityService::class);

        $oldAppointment = $this->appointment([
            'id' => 44,
            'id_schedule' => 8,
            'date' => '2026-08-24',
            'start_time' => '10:30:00',
            'status' => 'accepted',
            'updated_by' => 3,
        ]);
        $cancelledAppointment = $this->appointment([
            ...$oldAppointment->getAttributes(),
            'status' => 'cancelled',
            'updated_by' => 12,
        ]);
        $firstWaiting = new Waitlist;
        $firstWaiting->forceFill(['id' => 5, 'id_patient' => 19, 'status' => 'waiting']);
        $promotedAppointment = $this->appointment(['id' => 61]);

        $waitlistRepository->expects($this->once())
            ->method('findFirstWaitingForFreedAppointment')
            ->with(44)
            ->willReturn($firstWaiting);
        $availabilityService->expects($this->once())
            ->method('ensureAvailable')
            ->with(8, '2026-08-24', '10:30', 44);
        $userService->expects($this->once())
            ->method('getById')
            ->with(19)
            ->willReturn((object) ['name' => 'Paciente Primero']);
        $appointmentRepository->expects($this->once())
            ->method('create')
            ->with($this->callback(
                fn (array $data) => $data === [
                    'id_schedule' => 8,
                    'id_patient' => 19,
                    'name_patient' => 'Paciente Primero',
                    'date' => '2026-08-24',
                    'start_time' => '10:30',
                    'status' => 'accepted',
                    'created_by' => 12,
                    'updated_by' => 12,
                ]
            ))
            ->willReturn($promotedAppointment);
        $waitlistRepository->expects($this->once())
            ->method('update')
            ->with(5, [
                'id_fallback_appointment' => 61,
                'status' => 'fulfilled',
            ]);
        $appointmentRepository->expects($this->once())
            ->method('findNotificationContext')
            ->with(61)
            ->willReturn((object) [
                'doctor_name' => 'Ana Lopez',
                'clinic_name' => 'Zona 15',
                'date' => '2026-08-24',
                'start_time' => '10:30:00',
            ]);
        $notificationService->expects($this->once())
            ->method('dispatch')
            ->with(
                'waitlist_alert',
                19,
                $this->callback(
                    fn (string $message) => str_contains($message, 'Ana Lopez')
                        && str_contains($message, 'Zona 15')
                        && str_contains($message, '24/08/2026')
                        && str_contains($message, '10:30')
                )
            );

        $result = $this->service(
            $waitlistRepository,
            $appointmentRepository,
            $userService,
            $notificationService,
            $availabilityService,
        )->promoteIfFreed($oldAppointment, $cancelledAppointment);

        $this->assertSame($promotedAppointment, $result);
    }

    public function test_rescheduling_checks_the_waitlist_for_the_original_appointment(): void
    {
        $waitlistRepository = $this->createMock(WaitlistRepository::class);
        $waitlistRepository->expects($this->once())
            ->method('findFirstWaitingForFreedAppointment')
            ->with(44)
            ->willReturn(null);

        $result = $this->service(
            $waitlistRepository,
            $this->createStub(AppointmentRepository::class),
            $this->createStub(UserService::class),
            $this->createStub(NotificationService::class),
            $this->createStub(AppointmentAvailabilityService::class),
        )->promoteIfFreed(
            $this->appointment([
                'id' => 44,
                'id_schedule' => 8,
                'date' => '2026-08-24',
                'start_time' => '10:30:00',
                'status' => 'accepted',
            ]),
            $this->appointment([
                'id' => 44,
                'id_schedule' => 8,
                'date' => '2026-08-25',
                'start_time' => '11:00:00',
                'status' => 'rescheduled',
            ]),
        );

        $this->assertNull($result);
    }

    public function test_rescheduled_status_without_a_moved_slot_does_not_promote_anyone(): void
    {
        $waitlistRepository = $this->createMock(WaitlistRepository::class);
        $waitlistRepository->expects($this->never())
            ->method('findFirstWaitingForFreedAppointment');

        $oldAppointment = $this->appointment([
            'id' => 44,
            'id_schedule' => 8,
            'date' => '2026-08-24',
            'start_time' => '10:30:00',
            'status' => 'accepted',
        ]);
        $newAppointment = $this->appointment([
            ...$oldAppointment->getAttributes(),
            'status' => 'rescheduled',
        ]);

        $result = $this->service(
            $waitlistRepository,
            $this->createStub(AppointmentRepository::class),
            $this->createStub(UserService::class),
            $this->createStub(NotificationService::class),
            $this->createStub(AppointmentAvailabilityService::class),
        )->promoteIfFreed($oldAppointment, $newAppointment);

        $this->assertNull($result);
    }

    private function service(
        WaitlistRepository $waitlistRepository,
        AppointmentRepository $appointmentRepository,
        UserService $userService,
        NotificationService $notificationService,
        AppointmentAvailabilityService $availabilityService,
    ): WaitlistPromotionService {
        return new WaitlistPromotionService(
            $waitlistRepository,
            $appointmentRepository,
            $userService,
            $notificationService,
            $availabilityService,
        );
    }

    private function appointment(array $attributes): Appointment
    {
        $appointment = new Appointment;
        $appointment->forceFill($attributes);

        return $appointment;
    }
}
