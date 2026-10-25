<?php

namespace App\Policies;

use App\Models\Superadmin;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class UserPolicy
{
    public function viewAny(User $actor): bool
    {
        return $this->isActive($actor)
            && ($this->isSuperadmin($actor) || $this->administersAnyActiveClient($actor));
    }

    public function view(User $actor, User $target): bool
    {
        return $this->canManage($actor, $target);
    }

    public function update(User $actor, User $target): bool
    {
        return $this->canManage($actor, $target);
    }

    public function updateSensitive(User $actor, User $target): bool
    {
        return $this->isActive($actor) && $this->isSuperadmin($actor);
    }

    public function delete(User $actor, User $target): bool
    {
        return $this->isActive($actor) && $this->isSuperadmin($actor);
    }

    private function canManage(User $actor, User $target): bool
    {
        if (! $this->isActive($actor)) {
            return false;
        }

        if ($actor->id === $target->id || $this->isSuperadmin($actor)) {
            return true;
        }

        return DB::table('client_users AS administrator')
            ->join('client_users AS member', 'member.id_client', '=', 'administrator.id_client')
            ->join('clients', 'clients.id', '=', 'administrator.id_client')
            ->where('administrator.id_user', $actor->id)
            ->where('administrator.is_admin', true)
            ->where('administrator.is_active', true)
            ->where('member.id_user', $target->id)
            ->where('clients.is_active', true)
            ->exists();
    }

    private function administersAnyActiveClient(User $actor): bool
    {
        return DB::table('client_users')
            ->join('clients', 'clients.id', '=', 'client_users.id_client')
            ->where('client_users.id_user', $actor->id)
            ->where('client_users.is_admin', true)
            ->where('client_users.is_active', true)
            ->where('clients.is_active', true)
            ->exists();
    }

    private function isSuperadmin(User $actor): bool
    {
        return Superadmin::where('id_user', $actor->id)->exists();
    }

    private function isActive(User $actor): bool
    {
        return (bool) $actor->is_active;
    }
}
