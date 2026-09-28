<?php

namespace Tests\Unit\Events;

use App\Events\WaitlistChanged;
use PHPUnit\Framework\TestCase;

class WaitlistChangedTest extends TestCase
{
    public function test_broadcasts_to_patient_doctor_and_organization(): void
    {
        $event = new WaitlistChanged(
            waitlistId: 9,
            change: 'fulfilled',
            patientId: 13,
            doctorId: 7,
            clientId: 3,
        );

        $this->assertSame([
            'private-patients.13',
            'private-doctors.7',
            'private-organizations.3',
        ], array_map(fn ($channel) => $channel->name, $event->broadcastOn()));
        $this->assertSame('waitlist.changed', $event->broadcastAs());
        $this->assertSame([
            'waitlist_id' => 9,
            'change' => 'fulfilled',
        ], $event->broadcastWith());
    }
}
