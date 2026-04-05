<?php

namespace App\Repositories;

use App\Models\Specialty;

class SpecialtyRepository
{
    // Se obtienen todas las especialidades
    public function findAll()
    {
        return Specialty::all();
    }

    // Se obtiene una especialidad por su id
    public function findById($id)
    {
        return Specialty::findOrFail($id);
    }

    // Se crea una nueva especialidad
    public function create($data)
    {
        return Specialty::create($data);
    }

    // Se actualiza una especialidad
    public function update($id, $data)
    {
        $specialty = Specialty::findOrFail($id);
        $specialty->update($data);
        return $specialty;
    }

    // Se elimina una especialidad
    public function delete($id)
    {
        Specialty::destroy($id);
    }
}