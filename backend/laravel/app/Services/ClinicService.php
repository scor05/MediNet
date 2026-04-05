<?php

namespace App\Services;

use App\Repositories\ClinicRepository;

class ClinicService
{
    // Se inyecta el repositorio
    public function __construct(private ClinicRepository $repository)
    {
    }

    // Se obtienen todas las clínicas
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene una clínica por su ID
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea una nueva clínica
    public function create($data)
    {
        return $this->repository->create($data);
    }

    // Se actualiza una clínica
    public function update($id, $data)
    {
        return $this->repository->update($id, $data);
    }

    // Se elimina una clínica
    public function delete($id)
    {
        $this->repository->delete($id);
    }
}