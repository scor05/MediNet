<?php

namespace App\Repositories;

use App\Models\Waitlist;

class WaitlistRepository
{
    public function findAll()
    {
        return Waitlist::with([
            'patient',
            'targetAppointment',
            'fallbackAppointment'
        ])->get();
    }

    public function findById($id)
    {
        return Waitlist::with([
            'patient',
            'targetAppointment',
            'fallbackAppointment'
        ])->find($id);
    }

    public function findByPatient($patientId)
    {
        return Waitlist::with([
            'targetAppointment',
            'fallbackAppointment'
        ])
        ->where('id_patient', $patientId)
        ->get();
    }

    public function findDuplicate($patientId, $appointmentId)
    {
        return Waitlist::where('id_patient', $patientId)
            ->where('id_target_appointment', $appointmentId)
            ->first();
    }

    public function findActiveByTargetAppointment($appointmentId)
    {
        return Waitlist::where(
            'id_target_appointment',
            $appointmentId
        )
        ->where('status', 'waiting')
        ->get();
    }

    public function create(array $data)
    {
        return Waitlist::create($data);
    }

    public function update($id, array $data)
    {
        $waitlist = Waitlist::find($id);

        if (!$waitlist) {
            return null;
        }

        $waitlist->update($data);

        return $waitlist;
    }

    public function delete($id)
    {
        $waitlist = Waitlist::find($id);

        if (!$waitlist) {
            return false;
        }

        return $waitlist->delete();
    }

    public function findNotificationContext($id)
    {
        return Waitlist::with([
            'patient',
            'targetAppointment'
        ])->find($id);
    }
}
