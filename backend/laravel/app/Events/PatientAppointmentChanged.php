<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class PatientAppointmentChanged implements ShouldBroadcast, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly int $patientId,
        public readonly int $appointmentId,
        public readonly string $change,
    ) {}

    public function broadcastOn(): array
    {
        return [new PrivateChannel('patients.'.$this->patientId)];
    }

    public function broadcastAs(): string
    {
        return 'appointment.changed';
    }

    public function broadcastWith(): array
    {
        return [
            'appointment_id' => $this->appointmentId,
            'change' => $this->change,
        ];
    }
}
