<?php

namespace App\Services;

use App\Repositories\ScheduleRepository;
use Illuminate\Validation\ValidationException;

class ScheduleService
{
    // Se inyecta el repositorio
    public function __construct(private ScheduleRepository $repository) {}

    // Se obtienen los horarios de un doctor
    public function getByDoctor($doctorId)
    {
        return $this->repository->findByDoctor($doctorId);
    }

    public function getForSecretary(int $secretaryId)
    {
        return $this->repository->findForSecretary($secretaryId);
    }

    // Se obtiene un horario por su ID
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea un nuevo horario validando que el doctor no tenga conflicto de horario
    public function create($data, int $actorId)
    {
        if (! $this->repository->canCreateForDoctorAtClinic(
            $actorId,
            $data['id_doctor'],
            $data['id_clinic'],
        )) {
            throw ValidationException::withMessages([
                'id_clinic' => 'El doctor y la clínica deben pertenecer a una organización autorizada.',
            ]);
        }

        $this->validateConflict(
            $data['id_doctor'],
            $data['day_of_week'],
            $data['start_time'],
            $data['end_time']
        );

        return $this->repository->create($data);
    }

    // Se actualiza un horario validando que no haya conflicto
    public function update($id, $data, int $actorId)
    {
        $schedule = $this->repository->findById($id);

        $idDoctor = $schedule->id_doctor;
        $dayOfWeek = $schedule->day_of_week;
        $clinicId = $data['id_clinic'] ?? $schedule->id_clinic;

        if (! $this->repository->canCreateForDoctorAtClinic(
            $actorId,
            $idDoctor,
            $clinicId,
        )) {
            throw ValidationException::withMessages([
                'id_clinic' => 'No tienes permiso para editar este horario o usar esa clínica.',
            ]);
        }

        $startTime = $data['start_time'] ?? $schedule->start_time;
        $endTime = $data['end_time'] ?? $schedule->end_time;

        if (
            array_key_exists('start_time', $data) ||
            array_key_exists('end_time', $data)
        ) {
            $this->validateConflict(
                $idDoctor,
                $dayOfWeek,
                $startTime,
                $endTime,
                $id
            );
        }

        return $this->repository->update($id, $data);
    }

    // Se elimina un horario
    public function delete($id, int $actorId)
    {
        $schedule = $this->repository->findById($id);
        if (! $this->repository->canCreateForDoctorAtClinic(
            $actorId,
            $schedule->id_doctor,
            $schedule->id_clinic,
        )) {
            throw ValidationException::withMessages([
                'schedule' => 'No tienes permiso para eliminar este horario.',
            ]);
        }

        $this->repository->deactivate($id);
    }

    private function validateConflict(
        int $doctorId,
        int $dayOfWeek,
        string $startTime,
        string $endTime,
        ?int $excludeId = null
    ): void {
        $conflict = $this->repository->findOverlappingSchedule(
            $doctorId,
            $dayOfWeek,
            $startTime,
            $endTime,
            $excludeId
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'start_time' => ['Ya existe un horario en ese día y hora.'],
                'end_time' => ['Ya existe un horario en ese día y hora.'],
            ]);
        }
    }
}
