<?php

namespace App\Services;

use App\Repositories\PublicRepository;

class PublicService
{
    // Se inyecta el repositorio
    public function __construct(private PublicRepository $repository)
    {
    }

    // Se obtienen los doctores con horarios activos
    public function getDoctors(?int $clinicId)
    {
        return $this->repository->findDoctors($clinicId);
    }

    // Se obtienen las clínicas con horarios activos
    public function getClinics(?int $doctorId)
    {
        return $this->repository->findClinics($doctorId);
    }

    // Se obtienen los slots disponibles por doctor, clínica y fecha
    public function getSlots(int $doctorId, int $clinicId, string $date): array
    {
        return $this->repository->findSlots($doctorId, $clinicId, $date);
    }
}
