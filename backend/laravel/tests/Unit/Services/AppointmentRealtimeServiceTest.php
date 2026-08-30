<?php

namespace Tests\Unit\Services;

use App\Events\PatientAppointmentChanged;
use App\Models\Appointment;
use App\Services\AppointmentRealtimeService;
use Illuminate\Contracts\Events\Dispatcher;
use PHPUnit\Framework\TestCase;

class AppointmentRealtimeServiceTest extends TestCase
{
    public function test_created_appointment_dispatches_to_its_registered_patient(): void
    {
        $dispatcher = $this->createMock(Dispatcher::class);
        $dispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->callback($this->event(13, 57, 'created')));

        $this->service($dispatcher)->created($this->appointment([
            'id' => 57,
            'id_patient' => 13,
        ]));
    }

    public function test_external_appointment_does_not_dispatch_an_event(): void
    {
        $dispatcher = $this->createMock(Dispatcher::class);
        $dispatcher->expects($this->never())->method('dispatch');

        $this->service($dispatcher)->created($this->appointment([
            'id' => 57,
            'id_patient' => null,
        ]));
    }

    public function test_status_change_uses_the_new_status_as_change_type(): void
    {
        $dispatcher = $this->createMock(Dispatcher::class);
        $dispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->callback($this->event(13, 57, 'cancelled')));

        $this->service($dispatcher)->updated(
            $this->appointment([
                'id' => 57,
                'id_patient' => 13,
                'status' => 'accepted',
            ]),
            $this->appointment([
                'id' => 57,
                'id_patient' => 13,
                'status' => 'cancelled',
            ]),
        );
    }

    public function test_moved_appointment_is_classified_as_rescheduled(): void
    {
        $dispatcher = $this->createMock(Dispatcher::class);
        $dispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->callback($this->event(13, 57, 'rescheduled')));

        $this->service($dispatcher)->updated(
            $this->appointment([
                'id' => 57,
                'id_patient' => 13,
                'id_schedule' => 2,
                'date' => '2026-08-29',
                'start_time' => '09:00:00',
                'status' => 'accepted',
            ]),
            $this->appointment([
                'id' => 57,
                'id_patient' => 13,
                'id_schedule' => 2,
                'date' => '2026-08-30',
                'start_time' => '10:00:00',
                'status' => 'accepted',
            ]),
        );
    }

    public function test_reassignment_refreshes_the_old_and_new_patients(): void
    {
        $events = [];
        $dispatcher = $this->createMock(Dispatcher::class);
        $dispatcher->expects($this->exactly(2))
            ->method('dispatch')
            ->willReturnCallback(function (PatientAppointmentChanged $event) use (&$events): void {
                $events[] = [$event->patientId, $event->change];
            });

        $this->service($dispatcher)->updated(
            $this->appointment(['id' => 57, 'id_patient' => 13]),
            $this->appointment(['id' => 57, 'id_patient' => 19]),
        );

        $this->assertSame([
            [13, 'unlinked'],
            [19, 'linked'],
        ], $events);
    }

    private function service(Dispatcher $dispatcher): AppointmentRealtimeService
    {
        return new AppointmentRealtimeService($dispatcher);
    }

    private function appointment(array $attributes): Appointment
    {
        $appointment = new Appointment;
        $appointment->forceFill($attributes);

        return $appointment;
    }

    private function event(
        int $patientId,
        int $appointmentId,
        string $change,
    ): callable {
        return fn (PatientAppointmentChanged $event): bool => $event->patientId === $patientId
            && $event->appointmentId === $appointmentId
            && $event->change === $change;
    }
}
