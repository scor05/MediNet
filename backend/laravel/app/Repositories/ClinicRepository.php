<?php

namespace App\Repositories;

use App\Models\Clinic;

class ClinicRepository
{
    // Se obtienen todas las clínicas de un cliente
    public function findByClient(?int $clientId)
    {
        if ($clientId != null) {
            return Clinic::where('id_client', $clientId)->get();
        }
        return Clinic::all();
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