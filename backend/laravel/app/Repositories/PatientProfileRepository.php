<?php

namespace App\Repositories;

use App\Models\User;

class PatientProfileRepository
{
    public function getProfileById(int $userId): array
    {
        $user = User::findOrFail($userId);

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'is_active' => $user->is_active,
        ];
    }

    public function updateProfile(int $userId, array $data): array
    {
        $user = User::findOrFail($userId);
        $user->update($data);

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'is_active' => $user->is_active,
        ];
    }
}
