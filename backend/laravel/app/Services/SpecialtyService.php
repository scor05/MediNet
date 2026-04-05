<?php

namespace App\Services;

use App\Repositories\SpecialtyRepository;

class SpecialtyService
{
    // Se inyecta el repositorio
    public function __construct(private SpecialtyRepository $repository)
    {
    }

    // Se obtienen todas las especialidades
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene una especialidad por su id
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea una nueva especialidad
    public function create($data)
    {
        return $this->repository->create($data);
    }

    // Se actualiza una especialidad
    public function update($id, $data)
    {
        return $this->repository->update($id, $data);
    }

    // Se elimina una especialidad
    public function delete($id)
    {
        $this->repository->delete($id);
    }
}