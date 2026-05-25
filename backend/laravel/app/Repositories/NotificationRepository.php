<?php

namespace App\Repositories;

use App\Models\Notification;

class NotificationRepository
{
    // Se obtienen todas las notificaciones
    public function findAll()
    {
        return Notification::all();
    }

    // Se obtienen las notificaciones de un usuario
    public function findByUser(int $userId)
    {
        return Notification::where('id_user', $userId)
            ->orderBy('sent_at', 'desc')
            ->get();
    }

    // Se obtiene una notificación por su id
    public function findById(int $id)
    {
        return Notification::findOrFail($id);
    }

    // Se crea una nueva notificación
    public function create(array $data)
    {
        return Notification::create($data);
    }

    // Se elimina una notificación
    public function delete(int $id)
    {
        $notification = Notification::findOrFail($id);
        $notification->delete();
    }
}
