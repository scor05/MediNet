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

    // Se crea un nuevo usuario asignado a un cliente
    public function create($data)
    {
        return ClientUser::create($data);
    }

    // Se actualiza un usuario asignado a un cliente
    public function update($clientId, $userId, $data)
    {
        $record = ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->firstOrFail();
        $record->update($data);
        return $record;
    }

    // Se elimina la asignación de un usuario a un cliente
    public function delete($clientId, $userId)
    {
        ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->firstOrFail()
            ->delete();
    }
}