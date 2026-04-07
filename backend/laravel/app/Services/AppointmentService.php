<?php

namespace App\Services;

use App\Models\Appointment;
use Illuminate\Database\Eloquent\Collection;

class AppointmentService
{
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
        return Appointment::create($data);
    }

    public function update(int $id, array $data): ?Appointment
    {
        $appointment = Appointment::find($id);

        if (!$appointment) {
            return null;
        }

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
}
