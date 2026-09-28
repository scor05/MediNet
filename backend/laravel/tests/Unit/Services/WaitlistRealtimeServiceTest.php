<?php

namespace Tests\Unit\Services;

use App\Events\WaitlistChanged;
use App\Models\Appointment;
use App\Models\Waitlist;
use App\Repositories\AppointmentRepository;
use App\Services\WaitlistRealtimeService;
use Illuminate\Contracts\Events\Dispatcher;
use PHPUnit\Framework\TestCase;

class WaitlistRealtimeServiceTest extends TestCase
{
    public function test_created_waitlist_dispatches_to_all_affected_audiences(): void
    {
        $dispatcher = $this->createMock(Dispatcher::class);
        $appointments = $this->createMock(AppointmentRepository::class);
        $target = new Appointment;
        $target->forceFill(['id' => 44, 'id_schedule' => 8]);

        $appointments->expects($this->once())
            ->method('findById')
            ->with(44)
            ->willReturn($target);
        $appointments->expects($this->once())
            ->method('findRealtimeAudienceBySchedule')
            ->with(8)
            ->willReturn((object) [
                'doctor_id' => 7,
                'client_id' => 3,
            ]);
        $dispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->callback(function (WaitlistChanged $event): bool {
                return $event->waitlistId === 9
                    && $event->change === 'created'
                    && $event->patientId === 13
                    && $event->doctorId === 7
                    && $event->clientId === 3;
            }));

        $waitlist = new Waitlist;
        $waitlist->forceFill([
            'id' => 9,
            'id_patient' => 13,
            'id_target_appointment' => 44,
            'status' => 'waiting',
        ]);

        (new WaitlistRealtimeService($dispatcher, $appointments))
            ->created($waitlist);
    }

    public function test_status_change_uses_the_new_waitlist_status(): void
    {
        $dispatcher = $this->createMock(Dispatcher::class);
        $appointments = $this->createStub(AppointmentRepository::class);
        $target = new Appointment;
        $target->forceFill(['id' => 44, 'id_schedule' => 8]);
        $appointments->method('findById')->willReturn($target);
        $appointments->method('findRealtimeAudienceBySchedule')
            ->willReturn((object) ['doctor_id' => 7, 'client_id' => 3]);
        $dispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->callback(
                fn (WaitlistChanged $event): bool => $event->change === 'fulfilled'
            ));
        $old = new Waitlist;
        $old->forceFill([
            'id' => 9,
            'id_patient' => 13,
            'id_target_appointment' => 44,
            'status' => 'waiting',
        ]);
        $new = clone $old;
        $new->status = 'fulfilled';

        (new WaitlistRealtimeService($dispatcher, $appointments))
            ->updated($old, $new);
    }
}
