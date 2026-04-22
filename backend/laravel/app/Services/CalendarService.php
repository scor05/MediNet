<?php

namespace App\Services;
use App\Repositories\CalendarRepository;
use App\Repositories\UserRepository;
use RuntimeException;

class CalendarService
{
    // Se inyecta el repositorio
    public function __construct(protected CalendarRepository $calendarRepository, protected UserRepository $userRepository)
    {
    }

    // Se obtienen todas las citas de un doctor, con posibilidad de filtrarlas
    public function getDoctorCalendar(
        int $doctorId,
        ?int $clientId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo
    ): array {
        $appointments = $this->calendarRepository->getAppointmentsForDoctor(
            doctorId: $doctorId,
            clientId: $clientId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo: $dateTo
        );
        return $this->formatAppointments($appointments);
    }

    // Se obtienen todas las citas que maneja una secretaria, con posibilidad de filtrarlas
    public function getSecretaryCalendar(
        int $secretaryId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        // La secretaria ve las citas de todos los doctores del mismo cliente
        $clientId = $this->userRepository->getClientIdForUser($secretaryId);

        if (!$clientId) {
            throw new RuntimeException("La secretaria {$secretaryId} no tiene un cliente asociado.");
        }

        $appointments = $this->calendarRepository->getAppointmentsForSecretary(
            clientId: $clientId,
            doctorId: $doctorId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo: $dateTo,
        );

        return $this->formatAppointments($appointments);
    }

    // Se obtienen todas las citas de un paciente, con posibilidad de filtrarlas
    public function getPatientCalendar(
        int $patientId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $appointments = $this->calendarRepository->getAppointmentsForPatient(
            patientId: $patientId,
            doctorId: $doctorId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo: $dateTo,
        );

        return $this->formatAppointments($appointments);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private function formatAppointments(array $appointments): array
    {
        return array_map(function ($appt) {
            return [
                'id' => $appt->id,
                'date' => $appt->date,
                'start_time' => $appt->start_time,
                'status' => $appt->status,
                'doctor' => [
                    'id' => $appt->doctor_id,
                    'name' => $appt->doctor_name,
                ],
                'patient' => [
                    'id' => $appt->id_patient,
                    'name' => $appt->patient_name,
                ],
                'clinic' => [
                    'id' => $appt->clinic_id,
                    'name' => $appt->clinic_name,
                    'address' => $appt->clinic_address,
                ],
                'schedule_id' => $appt->id_schedule,
            ];
        }, $appointments);
    }
}
