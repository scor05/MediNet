<?php

namespace Tests\Unit\Services;

use App\Models\Appointment;
use App\Models\Waitlist;
use App\Repositories\AppointmentRepository;
use App\Repositories\WaitlistRepository;
use App\Services\WaitlistService;
use PHPUnit\Framework\TestCase;

class WaitlistServiceTest extends TestCase
{
    public function test_join_resolves_the_occupying_appointment_from_the_requested_slot(): void
    {
        $waitlistRepository = $this->createMock(WaitlistRepository::class);
        $appointmentRepository = $this->createMock(AppointmentRepository::class);
        $targetAppointment = new Appointment;
        $targetAppointment->id = 55;
        $createdWaitlist = new Waitlist;

        $appointmentRepository->expects($this->once())
            ->method('findOccupyingSlot')
            ->with(8, '2026-08-24', '10:30')
            ->willReturn($targetAppointment);
        $waitlistRepository->expects($this->once())
            ->method('findDuplicate')
            ->with(19, 55)
            ->willReturn(null);
        $waitlistRepository->expects($this->once())
            ->method('create')
            ->with([
                'id_patient' => 19,
                'id_target_appointment' => 55,
                'id_fallback_appointment' => null,
                'status' => 'waiting',
            ])
            ->willReturn($createdWaitlist);

        $result = (new WaitlistService(
            $waitlistRepository,
            $appointmentRepository,
        ))->join([
            'id_patient' => 19,
            'id_schedule' => 8,
            'date' => '2026-08-24',
            'start_time' => '10:30',
        ]);

        $this->assertSame($createdWaitlist, $result);
    }
}
