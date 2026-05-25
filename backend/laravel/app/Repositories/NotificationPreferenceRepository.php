<?php

namespace App\Repositories;

use App\Models\NotificationPreference;

class NotificationPreferenceRepository
{
    // Se obtienen las preferencias de un usuario
    public function findByUser(int $userId)
    {
        return NotificationPreference::where('id_user', $userId)->get();
    }

    // Se sincronizan las preferencias de un usuario (reemplaza las existentes)
    public function updatePreferences(int $userId, array $channels)
    {
        // Eliminar preferencias actuales del usuario
        NotificationPreference::where('id_user', $userId)->delete();

        // Insertar las nuevas preferencias
        foreach ($channels as $channel) {
            NotificationPreference::create([
                'id_user' => $userId,
                'channel' => $channel,
            ]);
        }

        return $this->findByUser($userId);
    }

    // Se eliminan todas las preferencias de un usuario
    public function deleteByUser(int $userId)
    {
        NotificationPreference::where('id_user', $userId)->delete();
    }
}
