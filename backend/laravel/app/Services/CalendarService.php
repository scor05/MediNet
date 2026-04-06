<?php

namespace App\Services;
use App\Repositories\CalendarRepository;

class CalendarService
{
    public function __construct(protected CalendarRepository $calendarRepository){}
    //get para doctor

    public function getDoctorCalendar(
        int $doctorId,
        ?int $clinetId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo
    ): array{
        $appointments = $this->calendarRepository->getAppointmentsForDoctor(
            doctorId: $doctorId,
            clientId: $clinetId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo: $dateTo
        );
        return $this-> formatAppointments($appointments);
    }
    //get para secretaria

    public function getSecretaryCalendar(
        int $secretaryId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        // La secretaria ve las citas de todos los doctores del mismo cliente
        $clientId = $this->calendarRepository->getClientIdForUser($secretaryId);

        if (!$clientId) {
            return [];
        }

        $appointments = $this->calendarRepository->getAppointmentsForSecretary(
            clientId: $clientId,
            doctorId: $doctorId,
            clinicId: $clinicId,
            dateFrom: $dateFrom,
            dateTo:   $dateTo,
        );

        return $this->formatAppointments($appointments);
    }
    //get para pacientes
    public function getPatientCalendar(
        int $patientId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $appointments = $this->calendarRepository->getAppointmentsForPatient(
            patientId: $patientId,
            doctorId:  $doctorId,
            clinicId:  $clinicId,
            dateFrom:  $dateFrom,
            dateTo:    $dateTo,
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
                'id'          => $appt->id,
                'date'        => $appt->date,
                'start_time'  => $appt->start_time,
                'status'      => $appt->status,
                'doctor'      => [
                    'id'   => $appt->doctor_id,
                    'name' => $appt->doctor_name,
                ],
                'patient'     => [
                    'id'   => $appt->patient_id,
                    'name' => $appt->patient_name,
                ],
                'clinic'      => [
                    'id'      => $appt->clinic_id,
                    'name'    => $appt->clinic_name,
                    'address' => $appt->clinic_address,
                ],
                'schedule_id' => $appt->id_schedule,
            ];
        }, $appointments);
    }
}
