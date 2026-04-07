<?php

namespace App\Services;

use App\Models\Appointment;
use Illuminate\Database\Eloquent\Collection;

class AppointmentService
{
    private array $blockingStatuses = ['requested', 'accepted'];

    public function index(): Collection
    {
        return Appointment::orderBy('date')
            ->orderBy('start_time')
            ->get();
    }

    public function show(int $id): ?Appointment
    {
        return Appointment::find($id);
    }

    public function store(array $data): Appointment
    {
        $this->validateConflict($data['id_schedule'],$data['date'],$data['start_time']);

        return Appointment::create($data);
    }

    public function update(int $id, array $data): ?Appointment
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return null;
        }

        $idSchedule = $data['id_schedule'] ?? $appointment->id_schedule;
        $date = $data['date'] ?? $appointment->date;
        $startTime = $data['start_time'] ?? $appointment->start_time;

        $this->validateConflict(
            $idSchedule,
            $date,
            $startTime,
            $appointment->id
        );

        $appointment->update($data);
        $appointment->refresh();

        return $appointment;
    }

    public function cancel(int $id, int $updatedBy): ?Appointment
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return null;
        }

        $appointment->update([
            'status' => 'cancelled',
            'updated_by' => $updatedBy,
        ]);

        $appointment->refresh();

        return $appointment;
    }

    private function validateConflict(
        int $idSchedule,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null
    ): void {
        $query = Appointment::where('id_schedule', $idSchedule)
            ->where('date', $date)
            ->where('start_time', $startTime)
            ->whereIn('status', $this->blockingStatuses);

        if ($ignoreAppointmentId !== null) {
            $query->where('id', '!=', $ignoreAppointmentId);
        }

        $conflictingAppointment = $query->first();

        if ($conflictingAppointment) {
            throw new \RuntimeException('Ya existe una cita en ese horario');
        }
    }
}

