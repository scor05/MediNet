<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AppointmentChanged implements ShouldBroadcast, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly int $appointmentId,
        public readonly string $change,
        public readonly ?int $patientId = null,
        public readonly ?int $doctorId = null,
        public readonly ?int $clientId = null,
    ) {}

    public function broadcastOn(): array
    {
        $channels = [];

        if ($this->patientId !== null) {
            $channels[] = new PrivateChannel('patients.'.$this->patientId);
        }
        if ($this->doctorId !== null) {
            $channels[] = new PrivateChannel('doctors.'.$this->doctorId);
        }
        if ($this->clientId !== null) {
            $channels[] = new PrivateChannel('organizations.'.$this->clientId);
        }

        return $channels;
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
