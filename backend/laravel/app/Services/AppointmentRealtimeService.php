<?php

namespace App\Services;

use App\Events\PatientAppointmentChanged;
use App\Models\Appointment;
use Illuminate\Contracts\Events\Dispatcher;

class AppointmentRealtimeService
{
    public function __construct(private Dispatcher $events) {}

    public function created(Appointment $appointment): void
    {
        $this->dispatch($appointment->id_patient, $appointment->id, 'created');
    }

    public function updated(Appointment $oldAppointment, Appointment $newAppointment): void
    {
        $oldPatientId = $this->patientId($oldAppointment->id_patient);
        $newPatientId = $this->patientId($newAppointment->id_patient);

        if ($oldPatientId !== null && $oldPatientId !== $newPatientId) {
            $this->dispatch($oldPatientId, $newAppointment->id, 'unlinked');
        }

        if ($newPatientId !== null) {
            $change = $oldPatientId !== $newPatientId
                ? 'linked'
                : $this->changeType($oldAppointment, $newAppointment);

            $this->dispatch($newPatientId, $newAppointment->id, $change);
        }
    }

    public function deleted(Appointment $appointment): void
    {
        $this->dispatch($appointment->id_patient, $appointment->id, 'deleted');
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

    private function dispatch(mixed $patientId, mixed $appointmentId, string $change): void
    {
        $patientId = $this->patientId($patientId);

        if ($patientId === null || $appointmentId === null) {
            return;
        }

        $this->events->dispatch(new PatientAppointmentChanged(
            patientId: $patientId,
            appointmentId: (int) $appointmentId,
            change: $change,
        ));
    }

    private function patientId(mixed $value): ?int
    {
        return $value === null ? null : (int) $value;
    }

    private function formatTime(mixed $time): string
    {
        return substr((string) $time, 0, 5);
    }
}
