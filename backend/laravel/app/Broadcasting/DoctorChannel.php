<?php

namespace App\Broadcasting;

use App\Models\User;

class DoctorChannel
{
    public function join(User $user, int $doctorId): bool
    {
        return $user->is_active && $user->id === $doctorId;
    }
}
