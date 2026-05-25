<?php

namespace App\Services;

use App\Repositories\NotificationRepository;

class NotificationService
{
    // Se inyecta el repositorio
    public function __construct(private NotificationRepository $repository)
    {
    }

    // Se obtienen todas las notificaciones
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtienen las notificaciones de un usuario
    public function getByUser(int $userId)
    {
        return $this->repository->findByUser($userId);
    }

    // Se obtiene una notificación por su id
    public function getById(int $id)
    {
        return $this->repository->findById($id);
    }

    // Se crea una nueva notificación (sent_at se establece en el backend)
    public function create(array $data)
    {
        $data['sent_at'] = now();
        return $this->repository->create($data);
    }

    // Se elimina una notificación
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }
}
