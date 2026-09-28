<?php

namespace App\Broadcasting;

use App\Models\ClientUser;
use App\Models\User;

class OrganizationChannel
{
    public function join(User $user, int $clientId): bool
    {
        if (! $user->is_active) {
            return false;
        }

        return ClientUser::query()
            ->where('id_user', $user->id)
            ->where('id_client', $clientId)
            ->where('role', 2)
            ->where('is_active', true)
            ->exists();
    }
}
