<?php

namespace Tests\Unit\Events;

use App\Events\AppointmentChanged;
use PHPUnit\Framework\TestCase;

class AppointmentChangedTest extends TestCase
{
    public function test_broadcasts_to_patient_doctor_and_organization(): void
    {
        $event = new AppointmentChanged(
            appointmentId: 57,
            change: 'backup_pending',
            patientId: 13,
            doctorId: 7,
            clientId: 3,
        );

        $this->assertSame([
            'private-patients.13',
            'private-doctors.7',
            'private-organizations.3',
        ], array_map(fn ($channel) => $channel->name, $event->broadcastOn()));
        $this->assertSame('appointment.changed', $event->broadcastAs());
        $this->assertSame([
            'appointment_id' => 57,
            'change' => 'backup_pending',
        ], $event->broadcastWith());
    }
}
