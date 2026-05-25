<?php

namespace App\Services;
use App\Repositories\CalendarRepository;

class CalendarService
{
    public function __construct(protected CalendarRepository $calendarRepository)
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

        $blockades = $this->calendarRepository->getBlockadesForDoctor(
            doctorId: $doctorId,
            dateFrom: $dateFrom,
            dateTo: $dateTo
        );

        return array_merge(
            $this->formatAppointments($appointments),
            $this->formatBlockades($blockades)
        );
    }

    // Se obtienen todas las citas que maneja una secretaria, con posibilidad de filtrarlas
    public function getSecretaryCalendar(
        int $secretaryId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
        ?string $status = null,
    ): array {
        $appointments = $this->calendarRepository->getAppointmentsForSecretary(
            secretaryId: $secretaryId,
            doctorId: $doctorId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo: $dateTo,
            status: $status,
        );

        $blockades = $this->calendarRepository->getBlockadesForSecretary(
            secretaryId: $secretaryId,
            dateFrom: $dateFrom,
            dateTo: $dateTo
        );

        return array_merge(
            $this->formatAppointments($appointments),
            $this->formatBlockades($blockades)
        );
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

    // Se obtienen las citas visibles para el calendario público
    public function getPublicCalendar(
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $appointments = $this->calendarRepository->getPublicAppointments(
            doctorId: $doctorId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo: $dateTo,
        );

        return $this->formatPublicAppointments($appointments);
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
                'duration' => $appt->appointment_duration,
                'created_at' => $appt->created_at,
                'created_by' => $appt->created_by,
                'updated_at' => $appt->updated_at,
                'updated_by' => $appt->updated_by,
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
                ],
                'schedule_id' => $appt->id_schedule,
            ];
        }, $appointments);
    }

    // Se formatean los bloqueos para incluirlos en la respuesta del calendario
    private function formatBlockades(array $blockades): array
    {
        return array_map(function ($blockade) {
            return [
                'id'          => $blockade->id,
                'type'        => 'blockade',
                'date'        => $blockade->date,
                'start_time'  => $blockade->start_time,
                'end_time'    => $blockade->end_time,
                'schedule_id' => $blockade->id_schedule,
                'doctor'      => [
                    'id'   => $blockade->doctor_id,
                    'name' => $blockade->doctor_name,
                ],
                'clinic'      => [
                    'id'   => $blockade->clinic_id,
                    'name' => $blockade->clinic_name,
                ],
            ];
        }, $blockades);
    }

    private function formatPublicAppointments(array $appointments): array
    {
        return array_map(function ($appt) {
            return [
                'id' => $appt->id,
                'schedule_id' => $appt->id_schedule,
                'date' => $appt->date,
                'start_time' => $appt->start_time,
                'status' => $appt->status,
                'created_at' => $appt->created_at,
                'created_by' => $appt->created_by,
                'updated_at' => $appt->updated_at,
                'updated_by' => $appt->updated_by,
                'doctor_id' => $appt->doctor_id,
                'doctor_name' => $appt->doctor_name,
                'clinic_id' => $appt->clinic_id,
                'clinic_name' => $appt->clinic_name,
                'duration' => $appt->appointment_duration,
            ];
        }, $appointments);
    }
}
