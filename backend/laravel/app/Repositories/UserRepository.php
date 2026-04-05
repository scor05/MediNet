<?php

namespace App\Repositories;

use App\Models\User;

class UserRepository
{
    // Se obtienen todos los usuarios
    public function findAll()
    {
        return User::all();
    }

    // Se obtiene un usuario por su ID
    public function findById($id)
    {
        return User::findOrFail($id);
    }

    // Se crea un nuevo usuario
    public function create($data)
    {
        return User::create($data);
    }

    // Se actualiza un usuario
    public function update($id, $data)
    {
        $user = User::findOrFail($id);
        $user->update($data);
        return $user;
    }

    // Se elimina un usuario
    public function delete($id)
    {
        User::findOrFail($id)->delete();
    }
}