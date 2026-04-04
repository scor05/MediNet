<?php

namespace App\Services;

use App\Repositories\ClientUserRepository;

class ClientUserService
{
    public function __construct(private ClientUserRepository $repository)
    {
    }

    public function getByClient($clientId)
    {
        return $this->repository->findByClient($clientId);
    }

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

    public function update($clientId, $userId, $data)
    {
        return $this->repository->update($clientId, $userId, $data);
    }

    public function delete($clientId, $userId)
    {
        $this->repository->delete($clientId, $userId);
    }
}