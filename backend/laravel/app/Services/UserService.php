<?php

namespace App\Services;

use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Hash;

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

    // Se crea un nuevo usuario
    public function create($data)
    {
        $data['password_hash'] = Hash::make($data['password']);
        unset($data['password']);
        return $this->repository->create($data);
    }

    // Se actualiza un usuario
    public function update($id, $data)
    {
        if (isset($data['password'])) {
            $data['password_hash'] = Hash::make($data['password']);
            unset($data['password']);
        }
        return $this->repository->update($id, $data);
    }

    // Se elimina un usuario
    public function delete($id)
    {
        $this->repository->delete($id);
    }
}