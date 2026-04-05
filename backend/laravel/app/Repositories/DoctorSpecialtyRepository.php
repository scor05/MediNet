<?php

namespace App\Repositories;

use App\Models\DoctorSpecialty;

class DoctorSpecialtyRepository
{
    // Se obtienen todas las especialidades asignadas a un doctor
    public function findByDoctor($doctorId)
    {
        return DoctorSpecialty::with(['specialty'])
            ->where('id_doctor', $doctorId)
            ->get();
    }

    // Se crea una nueva asignación de especialidad a un doctor
    public function create($data)
    {
        return DoctorSpecialty::create($data);
    }

    // Se elimina la asignación de una especialidad a un doctor
    public function delete($doctorId, $specialtyId)
    {
        DoctorSpecialty::where('id_doctor', $doctorId)
            ->where('id_specialty', $specialtyId)
            ->firstOrFail()
            ->delete();
    }
}