<?php

namespace App\Repositories;

use App\Models\User;
use Illuminate\Support\Facades\DB;

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
        $user = User::findOrFail($id);
        $user->delete();
    }

    // Retorna el client_id al que pertenece un usuario.
    public function getClientIdForUser(int $userId): ?int
    {
        $client = DB::table('client_users')
            ->where('id_user', $userId)
            ->where('is_active', true)
            ->first(['id_client']);

        return $client?->id_client;
    }
}