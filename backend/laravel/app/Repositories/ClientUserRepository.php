<?php

namespace App\Repositories;

use App\Models\ClientUser;

class ClientUserRepository
{
    public function findByClient($clientId)
    {
        return ClientUser::with(['user'])
            ->where('id_client', $clientId)
            ->get();
    }

    public function create($data)
    {
        return ClientUser::create($data);
    }

    public function update($clientId, $userId, $data)
    {
        $record = ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->firstOrFail();
        $record->update($data);
        return $record;
    }

    public function delete($clientId, $userId)
    {
        ClientUser::where('id_client', $clientId)
            ->where('id_user', $userId)
            ->firstOrFail()
            ->delete();
    }
}