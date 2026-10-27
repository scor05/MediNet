<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Waitlist;
use Illuminate\Support\Facades\DB;

class WaitlistPolicy
{
    public function viewAny(User $user): bool
    {
        return (bool) $user->is_active;
    }

    public function view(User $user, Waitlist $waitlist): bool
    {
        return $this->isActive($user)
            && ($this->isPatient($user, $waitlist)
                || $this->canManage($user, $waitlist));
    }

    public function update(User $user, Waitlist $waitlist): bool
    {
        return $this->isActive($user) && $this->canManage($user, $waitlist);
    }

    public function cancel(User $user, Waitlist $waitlist): bool
    {
        return $this->view($user, $waitlist);
    }

    public function participate(User $user, Waitlist $waitlist): bool
    {
        return $this->isActive($user) && $this->isPatient($user, $waitlist);
    }

    public function delete(User $user, Waitlist $waitlist): bool
    {
        return $this->isActive($user) && $this->canManage($user, $waitlist);
    }

    private function isActive(User $user): bool
    {
        return (bool) $user->is_active;
    }

    private function isPatient(User $user, Waitlist $waitlist): bool
    {
        return (int) $waitlist->id_patient === (int) $user->id;
    }

    private function canManage(User $user, Waitlist $waitlist): bool
    {
        return DB::table('waitlists AS w')
            ->join('appointments AS a', 'a.id', '=', 'w.id_target_appointment')
            ->join('schedules AS s', 's.id', '=', 'a.id_schedule')
            ->join('clinics AS c', 'c.id', '=', 's.id_clinic')
            ->where('w.id', $waitlist->id)
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
}
