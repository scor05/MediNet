<?php

namespace App\Services;

use App\Events\WaitlistChanged;
use App\Models\Waitlist;
use App\Repositories\AppointmentRepository;
use Illuminate\Contracts\Events\Dispatcher;

class WaitlistRealtimeService
{
    public function __construct(
        private Dispatcher $events,
        private AppointmentRepository $appointments,
    ) {}

    public function created(Waitlist $waitlist): void
    {
        $this->dispatch($waitlist, 'created');
    }

    public function updated(Waitlist $oldWaitlist, Waitlist $newWaitlist): void
    {
        $change = $oldWaitlist->status !== $newWaitlist->status
            ? (string) $newWaitlist->status
            : 'updated';

        $this->dispatch($newWaitlist, $change);
    }

    public function deleted(Waitlist $waitlist): void
    {
        $this->dispatch($waitlist, 'deleted');
    }

    private function dispatch(Waitlist $waitlist, string $change): void
    {
        if (
            $waitlist->id === null
            || $waitlist->id_patient === null
            || $waitlist->id_target_appointment === null
        ) {
            return;
        }

        $target = $this->appointments->findById(
            (int) $waitlist->id_target_appointment,
        );
        $audience = $target->id_schedule === null
            ? null
            : $this->appointments->findRealtimeAudienceBySchedule(
                (int) $target->id_schedule,
            );

        $this->events->dispatch(new WaitlistChanged(
            waitlistId: (int) $waitlist->id,
            change: $change,
            patientId: (int) $waitlist->id_patient,
            doctorId: $audience?->doctor_id === null
                ? null
                : (int) $audience->doctor_id,
            clientId: $audience?->client_id === null
                ? null
                : (int) $audience->client_id,
        ));
    }
}
