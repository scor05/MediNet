<?php

namespace App\Services;

use App\Repositories\ClientClinicRepository;

class ClientClinicService
{
    // Se inyecta el repositorio
    public function __construct(private ClientClinicRepository $repository)
    {
    }

    // Se obtienen todas las clínicas asignadas a un cliente
    public function getByClient($clientId)
    {
        return $this->repository->findByClient($clientId);
    }

    // Se crea una nueva clínica asignada a un cliente
    public function create($clientId, $data)
    {
        return $this->repository->create([
            'id_client' => $clientId,
            'id_clinic' => $data['id_clinic'],
            'is_active' => true,
        ]);
    }

    // Se actualiza una clínica asignada a un cliente
    public function update($clientId, $clinicId, $data)
    {
        return $this->repository->update($clientId, $clinicId, $data);
    }

    // Se elimina la asignación de una clínica a un cliente
    public function delete($clientId, $clinicId)
    {
        $this->repository->delete($clientId, $clinicId);
    }
}