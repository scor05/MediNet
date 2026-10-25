<?php

namespace App\Policies;

use App\Models\Appointment;
use App\Models\Schedule;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class AppointmentPolicy
{
    public function viewAny(User $user): bool
    {
        return (bool) $user->is_active;
    }

    public function view(User $user, Appointment $appointment): bool
    {
        return $this->isActive($user)
            && ($this->isPatient($user, $appointment)
                || $this->canManage($user, $appointment));
    }

    public function create(User $user, Schedule $schedule): bool
    {
        if (! $this->isActive($user)) {
            return false;
        }

        if ((int) $schedule->id_doctor === (int) $user->id) {
            return true;
        }

        return $this->isSecretaryForClinic($user, (int) $schedule->id_clinic);
    }

    public function update(User $user, Appointment $appointment): bool
    {
        return $this->isActive($user) && $this->canManage($user, $appointment);
    }

    public function cancel(User $user, Appointment $appointment): bool
    {
        return $this->isActive($user)
            && ($this->isPatient($user, $appointment)
                || $this->canManage($user, $appointment));
    }

    public function decide(User $user, Appointment $appointment): bool
    {
        return $this->update($user, $appointment);
    }

    public function reschedule(User $user, Appointment $appointment): bool
    {
        return $this->update($user, $appointment);
    }

    public function delete(User $user, Appointment $appointment): bool
    {
        return $this->update($user, $appointment);
    }

    private function isActive(User $user): bool
    {
        return (bool) $user->is_active;
    }

    private function isPatient(User $user, Appointment $appointment): bool
    {
        return $appointment->id_patient !== null
            && (int) $appointment->id_patient === (int) $user->id;
    }

    private function canManage(User $user, Appointment $appointment): bool
    {
        return DB::table('appointments AS a')
            ->join('schedules AS s', 's.id', '=', 'a.id_schedule')
            ->join('clinics AS c', 'c.id', '=', 's.id_clinic')
            ->where('a.id', $appointment->id)
            ->where(function ($query) use ($user) {
                $query->where('s.id_doctor', $user->id)
                    ->orWhereExists(function ($subquery) use ($user) {
                        $subquery->selectRaw('1')
                            ->from('client_users AS cu')
                            ->whereColumn('cu.id_client', 'c.id_client')
                            ->where('cu.id_user', $user->id)
                            ->where('cu.role', 2)
                            ->where('cu.is_active', true);
                    });
            })
            ->exists();
    }

    private function isSecretaryForClinic(User $user, int $clinicId): bool
    {
        return DB::table('clinics AS c')
            ->join('client_users AS cu', 'cu.id_client', '=', 'c.id_client')
            ->where('c.id', $clinicId)
            ->where('cu.id_user', $user->id)
            ->where('cu.role', 2)
            ->where('cu.is_active', true)
            ->exists();
    }
}
