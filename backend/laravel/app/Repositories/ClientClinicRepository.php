<?php

namespace App\Repositories;

use App\Models\ClientClinic;

class ClientClinicRepository
{
    // Se obtienen todas las clínicas asignadas a un cliente
    public function findByClient($clientId)
    {
        return ClientClinic::with(['clinic'])
            ->where('id_client', $clientId)
            ->get();
    }

    // Se crea una nueva clínica asignada a un cliente
    public function create($data)
    {
        return ClientClinic::create($data);
    }

    // Se actualiza una clínica asignada a un cliente
    public function update($clientId, $clinicId, $data)
    {
        $record = ClientClinic::where('id_client', $clientId)
            ->where('id_clinic', $clinicId)
            ->firstOrFail();
        $record->update($data);
        return $record;
    }

    // Se elimina la asignación de una clínica a un cliente
    public function delete($clientId, $clinicId)
    {
        ClientClinic::where('id_client', $clientId)
            ->where('id_clinic', $clinicId)
            ->firstOrFail()
            ->delete();
    }
}