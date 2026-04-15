<?php

namespace App\Services;

use App\Repositories\ClientUserRepository;
use Illuminate\Validation\ValidationException;

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

    // Se crea una nueva asignación de usuario a un cliente
    public function create($clientId, $data)
    {
        $this->validateConflict($clientId, $data["id_user"]);

        return $this->repository->create([
            'id_client' => $clientId,
            'id_user' => $data['id_user'],
            'role' => $data['role'],
            'is_admin' => $data['is_admin'] ?? false,
            'is_active' => true,
        ]);
    }

    // Se actualiza una asignación de usuario a un cliente
    public function update($clientId, $userId, $data)
    {
        return $this->repository->update($clientId, $userId, $data);
    }

    // Se elimina la asignación de un usuario a un cliente
    public function delete($clientId, $userId)
    {
        $this->repository->delete($clientId, $userId);
    }

    // Se verifica si un cliente ya tiene asignado a un usuario
    private function validateConflict(
        int $clientId,
        int $userId,
    ): void {
        $conflict = $this->repository->findClientUser(
            $clientId,
            $userId,
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'user' => ['El cliente ya tiene asignado a este usuario'],
            ]);
        }
    }
}