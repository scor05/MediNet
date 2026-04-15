<?php

namespace App\Services;

use App\Repositories\ClientClinicRepository;
use Illuminate\Validation\ValidationException;

class ClientClinicService
{
    // Se inyecta el repositorio
    public function __construct(private ClientClinicRepository $repository)
    {
    }

    // Se obtienen todas las clínicas asignadas a un cliente
    public function getByClient($clientId)
    {
        return $this->repository->findByClient($clientId);
    }

    // Se crea una nueva asignación de clínica a un cliente
    public function create($clientId, $data)
    {
        $this->validateConflict($clientId, $data["id_clinic"]);

        return $this->repository->create([
            'id_client' => $clientId,
            'id_clinic' => $data['id_clinic'],
            'is_active' => true,
        ]);
    }

    // Se actualiza una asignación de clínica a un cliente
    public function update($clientId, $clinicId, $data)
    {
        return $this->repository->update($clientId, $clinicId, $data);
    }

    // Se elimina la asignación de una clínica a un cliente
    public function delete($clientId, $clinicId)
    {
        $this->repository->delete($clientId, $clinicId);
    }

    // Se verifica si un cliente ya tiene asignada a una clínica
    private function validateConflict(
        int $clientId,
        int $clinicId,
    ): void {
        $conflict = $this->repository->findClientClinic(
            $clientId,
            $clinicId,
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'clinic' => ['El cliente ya tiene asignada a esta clínica'],
            ]);
        }
    }
}