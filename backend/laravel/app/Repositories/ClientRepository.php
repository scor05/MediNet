<?php

namespace App\Repositories;

use App\Models\Client;
use App\Models\ClientUser;
use Illuminate\Support\Facades\DB;

class ClientRepository
{
    // Se obtienen todos los clientes
    public function findAll()
    {
        return Client::all();
    }

    // Se obtiene un cliente por su id
    public function findById($id)
    {
        return Client::findOrFail($id);
    }

    // Se crea un nuevo cliente (con ID de user aparte para vincularlo a client_users)
    public function create($data)
    {
        $userId = $data['id_user'] ?? null;
        $clientData = collect($data)->except('id_user')->all();

        return DB::transaction(function () use ($clientData, $userId) {
            $client = Client::create($clientData);

            if ($userId !== null) {
                ClientUser::create([
                    'id_client' => $client->id,
                    'id_user'   => $userId,
                    'role'      => 0,
                    'is_admin'  => true,
                    'is_active' => true,
                ]);
            }

            return $client;
        });
    }

    // Se actualiza un cliente
    public function update($id, $data)
    {
        $client = Client::findOrFail($id);
        $client->update($data);
        return $client;
    }

    // Se elimina un cliente
    public function delete($id)
    {
        $client = Client::findOrFail($id);
        $client->delete();
    }
}
