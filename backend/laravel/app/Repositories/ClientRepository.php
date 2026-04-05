<?php

namespace App\Repositories;

use App\Models\Client;

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

    // Se crea un nuevo cliente
    public function create($data)
    {
        return Client::create($data);
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
        Client::destroy($id);
    }
}