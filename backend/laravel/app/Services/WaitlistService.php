<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Repositories\WaitlistRepository;
use Illuminate\Validation\ValidationException;

class WaitlistService
{
    private const VALID_STATUSES = [
        'waiting',
        'notified',
        'fulfilled',
        'cancelled',
    ];

    public function __construct(
        private WaitlistRepository $repository,
        private AppointmentRepository $appointmentRepository,
    ) {}

    public function getAll()
    {
        return $this->repository->findAll();
    }

    public function getById(int $id)
    {
        return $this->repository->findById($id);
    }

    public function getByPatient(int $patientId)
    {
        return $this->repository->findByPatient($patientId);
    }

    public function join(array $data)
    {
        if (! isset($data['id_target_appointment'])) {
            $targetAppointment = $this->appointmentRepository->findOccupyingSlot(
                $data['id_schedule'],
                $data['date'],
                $data['start_time'],
            );

            if ($targetAppointment === null) {
                throw ValidationException::withMessages([
                    'start_time' => ['No existe una cita activa para ese horario.'],
                ]);
            }

            $data['id_target_appointment'] = $targetAppointment->id;
        }

        unset($data['id_schedule'], $data['date'], $data['start_time']);

        $duplicate = $this->repository->findDuplicate(
            $data['id_patient'],
            $data['id_target_appointment']
        );

        if ($duplicate !== null) {
            if ($duplicate->status === 'cancelled') {
                return $this->repository->update($duplicate->id, [
                    'id_fallback_appointment' => null,
                    'status' => 'waiting',
                ]);
            }

            throw ValidationException::withMessages([
                'id_target_appointment' => ['Ya estás en la lista de espera para esta cita.'],
            ]);
        }

        return $this->repository->create([
            ...$data,
            'id_fallback_appointment' => $data['id_fallback_appointment'] ?? null,
            'status' => 'waiting',
        ]);
    }

    public function create(array $data)
    {
        return $this->join($data);
    }

    public function update(int $id, array $data)
    {
        if (isset($data['status'])) {
            $this->validateStatus($data['status']);
        }

        return $this->repository->update($id, $data);
    }

    public function leave(int $id): bool
    {
        return $this->repository->delete($id);
    }

    public function delete(int $id): bool
    {
        return $this->leave($id);
    }

    private function validateStatus(string $status): void
    {
        if (! in_array($status, self::VALID_STATUSES, true)) {
            throw ValidationException::withMessages([
                'status' => ['Estado de lista de espera inválido.'],
            ]);
        }
    }
}
