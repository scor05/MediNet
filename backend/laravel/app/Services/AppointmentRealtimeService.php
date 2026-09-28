<?php

namespace App\Services;

use App\Events\AppointmentChanged;
use App\Models\Appointment;
use App\Repositories\AppointmentRepository;
use Illuminate\Contracts\Events\Dispatcher;

class AppointmentRealtimeService
{
    public function __construct(
        private Dispatcher $events,
        private AppointmentRepository $appointments,
    ) {}

    public function created(Appointment $appointment): void
    {
        $this->dispatchFor($appointment, 'created');
    }

    public function updated(
        Appointment $oldAppointment,
        Appointment $newAppointment,
    ): void {
        $oldPatientId = $this->id($oldAppointment->id_patient);
        $newPatientId = $this->id($newAppointment->id_patient);
        $oldAudience = $this->audience($oldAppointment);
        $newAudience = $this->audience($newAppointment);

        if ($oldPatientId !== null && $oldPatientId !== $newPatientId) {
            $this->dispatch(
                appointmentId: (int) $newAppointment->id,
                change: 'unlinked',
                patientId: $oldPatientId,
            );
        }

        if ($this->staffAudienceChanged($oldAudience, $newAudience)) {
            $this->dispatch(
                appointmentId: (int) $newAppointment->id,
                change: 'unlinked',
                doctorId: $oldAudience?->doctor_id,
                clientId: $oldAudience?->client_id,
            );
        }

        $change = $oldPatientId !== $newPatientId
            ? 'linked'
            : $this->changeType($oldAppointment, $newAppointment);

        $this->dispatch(
            appointmentId: (int) $newAppointment->id,
            change: $change,
            patientId: $newPatientId,
            doctorId: $newAudience?->doctor_id,
            clientId: $newAudience?->client_id,
        );
    }

    public function deleted(Appointment $appointment): void
    {
        $this->dispatchFor($appointment, 'deleted');
    }

    private function dispatchFor(Appointment $appointment, string $change): void
    {
        if ($appointment->id === null) {
            return;
        }

        $audience = $this->audience($appointment);
        $this->dispatch(
            appointmentId: (int) $appointment->id,
            change: $change,
            patientId: $this->id($appointment->id_patient),
            doctorId: $audience?->doctor_id,
            clientId: $audience?->client_id,
        );
    }

    private function dispatch(
        int $appointmentId,
        string $change,
        mixed $patientId = null,
        mixed $doctorId = null,
        mixed $clientId = null,
    ): void {
        $patientId = $this->id($patientId);
        $doctorId = $this->id($doctorId);
        $clientId = $this->id($clientId);

        if ($patientId === null && $doctorId === null && $clientId === null) {
            return;
        }

        $this->events->dispatch(new AppointmentChanged(
            appointmentId: $appointmentId,
            change: $change,
            patientId: $patientId,
            doctorId: $doctorId,
            clientId: $clientId,
        ));
    }

    private function audience(Appointment $appointment): ?object
    {
        if ($appointment->id_schedule === null) {
            return null;
        }

        return $this->appointments->findRealtimeAudienceBySchedule(
            (int) $appointment->id_schedule,
        );
    }

    private function staffAudienceChanged(?object $old, ?object $new): bool
    {
        return $this->id($old?->doctor_id) !== $this->id($new?->doctor_id)
            || $this->id($old?->client_id) !== $this->id($new?->client_id);
    }

    private function changeType(
        Appointment $oldAppointment,
        Appointment $newAppointment,
    ): string {
        if ($oldAppointment->status !== $newAppointment->status) {
            return (string) $newAppointment->status;
        }

        if (
            $oldAppointment->id_schedule !== $newAppointment->id_schedule
            || (string) $oldAppointment->date !== (string) $newAppointment->date
            || $this->formatTime($oldAppointment->start_time)
                !== $this->formatTime($newAppointment->start_time)
        ) {
            return 'rescheduled';
        }

        return 'updated';
    }

    private function id(mixed $value): ?int
    {
        return $value === null ? null : (int) $value;
    }

    private function formatTime(mixed $time): string
    {
        return substr((string) $time, 0, 5);
    }
}
