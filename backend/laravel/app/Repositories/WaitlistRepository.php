<?php

namespace App\Repositories;

use App\Models\Waitlist;

class WaitlistRepository
{
    private const RELATIONS = [
        'patient',
        'targetAppointment',
        'fallbackAppointment',
    ];

    public function findAll()
    {
        return Waitlist::with(self::RELATIONS)
            ->orderBy('created_at')
            ->orderBy('id')
            ->get();
    }

    public function findById(int $id): ?Waitlist
    {
        return Waitlist::with(self::RELATIONS)->find($id);
    }

    public function findByPatient(int $patientId)
    {
        return Waitlist::with(['targetAppointment', 'fallbackAppointment'])
            ->where('id_patient', $patientId)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->get();
    }

    public function findDuplicate(int $patientId, int $appointmentId): ?Waitlist
    {
        return Waitlist::where('id_patient', $patientId)
            ->where('id_target_appointment', $appointmentId)
            ->first();
    }

    /**
     * Resolve the original queue when a previously promoted fallback frees
     * the slot again, then lock and return the oldest waiting registration.
     */
    public function findFirstWaitingForFreedAppointment(int $appointmentId): ?Waitlist
    {
        $rootAppointmentId = Waitlist::where(
            'id_fallback_appointment',
            $appointmentId
        )->value('id_target_appointment') ?? $appointmentId;

        return Waitlist::where('id_target_appointment', $rootAppointmentId)
            ->where('status', 'waiting')
            ->orderBy('created_at')
            ->orderBy('id')
            ->lockForUpdate()
            ->first();
    }

    public function create(array $data): Waitlist
    {
        return Waitlist::create($data);
    }

    public function update(int $id, array $data): ?Waitlist
    {
        $waitlist = Waitlist::find($id);

        if ($waitlist === null) {
            return null;
        }

        $waitlist->update($data);

        return $waitlist->refresh();
    }

    public function delete(int $id): bool
    {
        $waitlist = Waitlist::find($id);

        return $waitlist?->delete() ?? false;
    }
}
