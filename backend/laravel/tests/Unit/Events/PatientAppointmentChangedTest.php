<?php

namespace Tests\Unit\Events;

use App\Events\PatientAppointmentChanged;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use PHPUnit\Framework\TestCase;

class PatientAppointmentChangedTest extends TestCase
{
    public function test_event_uses_a_private_patient_channel_and_minimal_payload(): void
    {
        $event = new PatientAppointmentChanged(13, 57, 'accepted');
        $channels = $event->broadcastOn();

        $this->assertInstanceOf(ShouldBroadcast::class, $event);
        $this->assertInstanceOf(ShouldDispatchAfterCommit::class, $event);
        $this->assertCount(1, $channels);
        $this->assertInstanceOf(PrivateChannel::class, $channels[0]);
        $this->assertSame('private-patients.13', $channels[0]->name);
        $this->assertSame('appointment.changed', $event->broadcastAs());
        $this->assertSame([
            'appointment_id' => 57,
            'change' => 'accepted',
        ], $event->broadcastWith());
    }
}
