<?php

namespace App\Services;

use App\Repositories\UserRepository;

class UserService
{
    // Se inyecta el repositorio
    public function __construct(private UserRepository $repository)
    {
    }

    // Se obtienen todos los usuarios
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene un usuario por su ID
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Retorna el client_id al que pertenece un usuario.
    public function getClientIdForUser(int $userId): ?int
    {
        return $this->repository->getClientIdForUser($userId);
    }

    // Se crea un nuevo usuario
    public function create($data)
    {
        return $this->repository->create($data);
    }

    // Se actualiza un usuario
    public function update($id, $data)
    {
        return $this->repository->update($id, $data);
    }

    // Se guarda el token FCM del usuario
    public function updateFcmToken(int $id, string $fcmToken)
    {
        return $this->repository->updateFcmToken($id, $fcmToken);
    }

    // Se elimina un usuario
    public function delete($id)
    {
        $this->repository->delete($id);
    }


    // Se obtiene información básica del usuario
    public function getProfile($id)
    {
        return $this->repository->getProfile($id);
    }

    // Se obtiene los usuarios que no están asociados ya al cliente y que no son superadmins
    public function getAvailableForClient(int $clientId, string $search)
    {
        return $this->repository->findAvailableForClient($clientId, $search);
    }

    // Se obtiene la información básica de un paciente (para secretarias)
    public function getPatientBasicInfo(int $patientId, int $secretaryId)
    {
        return $this->repository->getPatientBasicInfo($patientId, $secretaryId);
    }

    // Se obtienen todos los usuarios que no son superadmins
    public function getAvailable(string $search)
    {
        return $this->repository->findAvailable($search);
    }
}
