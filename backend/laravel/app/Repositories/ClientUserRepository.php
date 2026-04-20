<?php

namespace App\Repositories;

use App\Models\ClientUser;

class ClientUserRepository
{
    // Se obtienen todos los usuarios asignados a un cliente
    public function findByClient($clientId)
    {
        return ClientUser::with(['user'])
            ->where('id_client', $clientId)
            ->get();
    }

    // Se crea una nueva asignación de usuario a un cliente
    public function create($data)
    {
        return ClientUser::create($data);
    }

    // Se actualiza una asignación de usuario a un cliente
    public function update($clientId, $userId, $data)
    {
        ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->firstOrFail();

        ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->update($data);

        return ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->first();
    }

    // Se elimina la asignación de un usuario a un cliente
    public function delete($clientId, $userId)
    {
        ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->firstOrFail();

        ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->delete();
    }

    // Se obtiene una fila de la tabla si un cliente específico tiene asignado a un usuario específico
    public function findClientUser(int $clientId, int $userId)
    {
        return ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->first();
    }
}
