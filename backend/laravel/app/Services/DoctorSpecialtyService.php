<?php

namespace App\Services;

use App\Repositories\DoctorSpecialtyRepository;
use Illuminate\Validation\ValidationException;

class DoctorSpecialtyService
{
    // Se inyecta el repositorio
    public function __construct(private DoctorSpecialtyRepository $repository)
    {
    }

    // Se obtienen todas las clínicas asignadas a un cliente
    public function getByDoctor($doctorId)
    {
        return $this->repository->findByDoctor($doctorId);
    }

    // Se crea una nueva asignación de especialidad a un doctor
    public function create($doctorId, $data)
    {
        $this->validateConflict($doctorId, $data['id_specialty']);

        return $this->repository->create([
            'id_doctor' => $doctorId,
            'id_specialty' => $data['id_specialty'],
        ]);
    }

    // Se elimina la asignación de una especialidad a un doctor
    public function delete($doctorId, $specialtyId)
    {
        $this->repository->delete($doctorId, $specialtyId);
    }

    // Se verifica si un doctor ya tiene una especialidad
    private function validateConflict(
        int $doctorId,
        int $specialtyId,
    ): void {
        $conflict = $this->repository->findDoctorSpecialty(
            $doctorId,
            $specialtyId,
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'specialty' => ['El doctor ya tiene esta especialidad'],
            ]);
        }
    }
}