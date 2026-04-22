<?php

namespace App\Services;

use App\Repositories\ClinicRepository;

class ClinicService
{
    // Se inyecta el repositorio
    public function __construct(private ClinicRepository $repository)
    {
    }

    // Se obtienen todas las clínicas de un cliente
    public function getByClient(?int $clientId)
    {
        return $this->repository->findByClient($clientId);
    }

    // Se obtiene una clínica por su ID
    public function getById(int $id)
    {
        return $this->repository->findById($id);
    }

    // Se crea una nueva clínica
    public function create(array $data)
    {
        return $this->repository->create($data);
    }

    // Se actualiza una clínica
    public function update(int $id, array $data)
    {
        return $this->repository->update($id, $data);
    }

    // Se elimina una clínica
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }
}