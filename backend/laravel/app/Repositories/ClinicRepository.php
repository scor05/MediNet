<?php

namespace App\Repositories;

use App\Models\Clinic;

class ClinicRepository
{
    // Se obtienen todas las clínicas
    public function findAll()
    {
        return Clinic::all();
    }

    // Clínicas de las organizaciones en las que el usuario está activo.
    public function findForUser(int $userId)
    {
        return Clinic::query()
            ->select('clinics.*')
            ->join('client_users', 'client_users.id_client', '=', 'clinics.id_client')
            ->where('client_users.id_user', $userId)
            ->where('client_users.is_active', true)
            ->where('clinics.is_active', true)
            ->distinct()
            ->orderBy('clinics.name')
            ->get();
    }

    // Se obtienen todas las clínicas de un cliente
    public function findByClient(int $clientId)
    {
        return Clinic::where('id_client', $clientId)->get();
    }

    // Se obtiene una clínica por su ID
    public function findById($id)
    {
        return Clinic::findOrFail($id);
    }

    // Se crea una nueva clínica
    public function create($data)
    {
        return Clinic::create($data);
    }

    // Se actualiza una clínica
    public function update($id, $data)
    {
        $clinic = Clinic::findOrFail($id);
        $clinic->update($data);

        return $clinic;
    }

    // Se elimina una clínica
    public function delete($id)
    {
        $clinic = Clinic::findOrFail($id);
        $clinic->delete();
    }
}
