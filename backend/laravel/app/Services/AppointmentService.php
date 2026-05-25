<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Repositories\ScheduleBlockadeRepository;
use App\Services\UserService;
use App\Services\NotificationService;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class AppointmentService
{
    // Se inyecta el repositorio
    public function __construct(private AppointmentRepository $repository,
        private UserService $userService,
        private ScheduleBlockadeRepository $blockadeRepository,
        private NotificationService $notificationService)
    {
    }

    // Se obtienen todas las citas
    public function getAll()
    {
        return $this->repository->findAll();
    }

    // Se obtiene una cita por su id
    public function getById($id)
    {
        return $this->repository->findById($id);
    }

    // Se crea una nueva cita
    public function create($data)
    {
        $this->validateConflict(
            $data['id_schedule'],
            $data['date'],
            $data['start_time']
        );

        if (array_key_exists('id_patient', $data)) {
            $data['name_patient'] = $this->userService->getById($data['id_patient'])?->name;
        }

        return $this->repository->create($data);
    }

    // Se actualiza una cita
    public function update(int $id, array $data)
    {
        $appointment = $this->repository->findById($id);

        $idSchedule = $appointment->id_schedule;
        $date = $data['date'] ?? $appointment->date;
        $startTime = $data['start_time'] ?? $appointment->start_time;

        if (
            array_key_exists('date', $data) ||
            array_key_exists('start_time', $data) ||
            (($data['status'] ?? null) === 'accepted')
        ) {
            $this->validateConflict(
                $idSchedule,
                $date,
                $startTime,
                $id
            );
        }

        if (array_key_exists('id_patient', $data)) {
            $data['name_patient'] = $this->userService->getById($data['id_patient'])?->name;
        }

        $appointment = DB::transaction(function () use ($id, $data) {
            $appointment = $this->repository->update($id, $data);

            if (in_array($appointment->status, ['accepted', 'rejected'], true)) {
                $this->notifyUpdatedAppointment($appointment->id, $appointment->id_patient);
            }

            return $appointment;
        });

        return $appointment;
    }

    private function notifyUpdatedAppointment(int $appointment_id, int $patient_id)
    {

        $ctx = $this->repository->findNotificationContext($appointment_id);
        $appointment = $this->repository->findById($appointment_id);
        $status = ($appointment->status === 'accepted') ? 'acceptance' : 'rejection';

        // Enviar notificación a paciente
        $patient_msg = ($status === 'acceptance')
            ? "Su cita con el Dr.{$ctx->doctor_name} el {$ctx->date} a las {$ctx->start_time} ha sido aceptada."
            : "Su cita con el Dr.{$ctx->doctor_name} el {$ctx->date} a las {$ctx->start_time} ha sido rechazada.";

        $this->notificationService->create([
            'id_user' => $patient_id,
            'type' => $status,
            'message' => $patient_msg,
            'channel' => 'push',
        ]);

        // Enviar notificación a secretarias
        $secretaries = $this->repository->findSecretariesByClient($ctx->client_id);
        $secretary_msg = ($status === 'acceptance')
            ? "Se ha aceptado la cita con el paciente {$ctx->patient_name} con Dr.{$ctx->doctor_name} el {$ctx->date} a las {$ctx->start_time}."
            : "La cita con el paciente {$ctx->patient_name} con Dr.{$ctx->doctor_name} del {$ctx->date} a las {$ctx->start_time} fue rechazada.";

        foreach ($secretaries as $s) {
            $this->notificationService->create([
                'id_user' => $s->id,
                'type' => $status,
                'message' => $secretary_msg,
                'channel' => 'push',
            ]);
        }
    }

    // Se elimina una cita
    public function delete(int $id)
    {
        $this->repository->delete($id);
    }

    // Se valida si la cita por crear/actualizar no genera conflictos
    private function validateConflict(
        int $idSchedule,
        string $date,
        string $startTime,
        ?int $ignoreAppointmentId = null
    ): void {
        $conflict = $this->repository->findAppointment(
            $idSchedule,
            $date,
            $startTime,
            $ignoreAppointmentId
        );

        if ($conflict) {
            throw ValidationException::withMessages([
                'start_time' => ['Ya existe una cita en ese horario'],
            ]);
        }

        $blockade = $this->blockadeRepository->findBlockadeAtTime(
            $idSchedule,
            $date,
            $startTime
        );

        if ($blockade) {
            throw ValidationException::withMessages([
                'start_time' => ['Ese horario está bloqueado y no permite nuevas citas.'],
            ]);
        }
    }
}
