<?php

namespace App\Services;

use App\Repositories\AppointmentRepository;
use App\Repositories\PublicRepository;
use Illuminate\Support\Facades\DB;

class PublicService
{
    // Se inyecta el repositorio
    public function __construct(
        private PublicRepository $repository,
        private AppointmentRepository $appointmentRepository,
        private NotificationService $notificationService,
        private AppointmentAvailabilityService $availabilityService,
    ) {}

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

    // Se crea una solicitud pública de cita
    public function createAppointment(array $data)
    {
        $this->availabilityService->ensureAvailable(
            $data['id_schedule'],
            $data['date'],
            $data['start_time'],
        );

        $data['status'] = 'requested';
        $data['created_by'] = $data['id_patient'];
        $data['updated_by'] = $data['id_patient'];

        $appointment = DB::transaction(function () use ($data) {
            $appointment = $this->repository->createAppointment($data);
            $this->notifyRequestedAppointment($appointment->id);

            return $appointment;
        });

        return $appointment;
    }

    // Se notifica a secretarias del cliente
    private function notifyRequestedAppointment(int $appointment_id)
    {
        $context = $this->appointmentRepository->findNotificationContext($appointment_id);
        $secretaries = $this->appointmentRepository->findSecretariesByClient($context->client_id);

        foreach ($secretaries as $s) {
            $this->notificationService->create([
                'id_user' => $s->id,
                'type' => 'reminder',
                'message' => "Se ha solicitado una cita para {$context->patient_name} con Dr.{$context->doctor_name} el {$context->date} a las {$context->start_time}.",
                'channel' => 'push',
            ]);
        }
    }
}
