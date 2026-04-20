<?php

namespace App\Services;

use App\Repositories\ClientRepository;
use Illuminate\Validation\ValidationException;

class ClientService
{
    // Se inyecta el repositorio
    public function __construct(private ClientRepository $repository)
    {
    }

    // Se obtienen todos los clientes
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene un cliente por su id
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea un nuevo cliente
    public function create($data)
    {
        return $this->repository->create($data);
    }

    // Se actualiza un cliente
    public function update($id, $data)
    {
        if (empty($data)) {
            throw ValidationException::withMessages([
                'data' => ['No fields provided for update.'],
            ]);
        }

        return $this->repository->update($id, $data);
    }

    // Se elimina un cliente
    public function delete($id)
    {
        $this->repository->delete($id);
    }

    // Retorna la información del cliente con sus usuarios
    public function getClientSummary($id)
    {
        return $this->repository->getClientSummary($id);
    }
}
