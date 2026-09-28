<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Events\ShouldDispatchAfterCommit;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class WaitlistChanged implements ShouldBroadcast, ShouldDispatchAfterCommit
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly int $waitlistId,
        public readonly string $change,
        public readonly int $patientId,
        public readonly ?int $doctorId = null,
        public readonly ?int $clientId = null,
    ) {}

    public function broadcastOn(): array
    {
        $channels = [new PrivateChannel('patients.'.$this->patientId)];

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
        return 'waitlist.changed';
    }

    public function broadcastWith(): array
    {
        return [
            'waitlist_id' => $this->waitlistId,
            'change' => $this->change,
        ];
    }
}
