<?php

namespace App\Broadcasting;

use App\Models\User;

class PatientChannel
{
    public function join(User $user, int $patientId): bool
    {
        return $user->id === $patientId;
    }
}
