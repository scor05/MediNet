<?php

namespace App\Services;

use App\Repositories\ClientUserRepository;

class ClientUserService
{
    // Se inyecta el repositorio
    public function __construct(private ClientUserRepository $repository)
    {
    }

    // Se obtienen todos los usuarios asignados a un cliente
    public function getByClient($clientId)
    {
        return $this->repository->findByClient($clientId);
    }

    // Se crea un nuevo usuario asignado a un cliente
    public function create($clientId, $data)
    {
        return $this->repository->create([
            'id_client' => $clientId,
            'id_user' => $data['id_user'],
            'role' => $data['role'],
            'is_admin' => $data['is_admin'] ?? false,
            'is_active' => true,
        ]);
    }

    // Se actualiza un usuario asignado a un cliente
    public function update($clientId, $userId, $data)
    {
        return $this->repository->update($clientId, $userId, $data);
    }

    // Se elimina la asignación de un usuario a un cliente
    public function delete($clientId, $userId)
    {
        $this->repository->delete($clientId, $userId);
    }
}