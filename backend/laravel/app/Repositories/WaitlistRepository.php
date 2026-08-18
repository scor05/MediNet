<?php

namespace App\Repositories;

use App\Models\Waitlist;
use Illuminate\Support\Facades\DB;

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
        return DB::table('waitlists')
            ->join(
                'appointments AS target',
                'target.id',
                '=',
                'waitlists.id_target_appointment'
            )
            ->join('schedules', 'schedules.id', '=', 'target.id_schedule')
            ->join('users AS doctor', 'doctor.id', '=', 'schedules.id_doctor')
            ->join('clinics', 'clinics.id', '=', 'schedules.id_clinic')
            ->where('waitlists.id_patient', $patientId)
            ->select([
                'waitlists.*',
                'doctor.name AS doctor_name',
                'clinics.name AS clinic_name',
                'target.date AS target_date',
                'target.start_time AS target_start_time',
            ])
            ->orderByDesc('waitlists.created_at')
            ->orderByDesc('waitlists.id')
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
