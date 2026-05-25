<?php

namespace App\Services;

use App\Repositories\NotificationPreferenceRepository;

class NotificationPreferenceService
{
    // Se inyecta el repositorio
    public function __construct(private NotificationPreferenceRepository $repository)
    {
    }

    // Se obtienen las preferencias de un usuario
    public function getByUser(int $userId)
    {
        return $this->repository->findByUser($userId);
    }

    // Se actualizan las preferencias de un usuario
    public function updatePreferences(int $userId, array $channels)
    {
        return $this->repository->updatePreferences($userId, $channels);
    }

    // Se eliminan las preferencias de un usuario
    public function deleteByUser(int $userId)
    {
        $this->repository->deleteByUser($userId);
    }
}
