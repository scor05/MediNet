<?php

namespace App\Services;

use App\Repositories\PatientProfileRepository;

class PatientProfileService
{
    public function __construct(private PatientProfileRepository $repository)
    {
    }

    public function getProfile(int $userId): array
    {
        return $this->repository->getProfileById($userId);
    }

    public function updateProfile(int $userId, array $data): array
    {
        // Solo se permiten actualizar 'name' y 'phone' (email permanece de solo lectura)
        $allowedData = array_intersect_key($data, array_flip(['name', 'phone']));

        return $this->repository->updateProfile($userId, $allowedData);
    }
}
