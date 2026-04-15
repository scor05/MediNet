<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class CalendarRepository
{
    // Query base que une appointments, schedules, clinics y users.Devuelve un QueryBuilder.
    private function baseQuery()
    {
        return DB::table('appointments AS a')
            ->join('schedules AS s', 's.id', '=', 'a.id_schedule')
            ->join('clinics AS cl', 'cl.id', '=', 's.id_clinic')
            ->join('users AS doctor', 'doctor.id', '=', 's.id_doctor')
            ->leftJoin('users AS patient', 'patient.id', '=', 'a.id_patient')
            ->select([
                'a.id',
                'a.id_schedule',
                'a.date',
                'a.start_time',
                'a.status',
                'doctor.id   AS doctor_id',
                'doctor.name AS doctor_name',
                'a.id_patient AS patient_id',
                DB::raw('COALESCE(patient.name, a.name_patient) AS patient_name'),
                'cl.id        AS clinic_id',
                'cl.name      AS clinic_name',
                'cl.address   AS clinic_address',
            ]);
    }

    // Se obtienen todas las citas de un doctor, pudiendose filtrar por cliente, clínica y rango de fechas.
    public function getAppointmentsForDoctor(
        int $doctorId,
        ?int $clientId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = $this->baseQuery()
            ->where('s.id_doctor', $doctorId);

        // Filtro por cliente (el doctor debe pertenecer a ese cliente)
        if ($clientId !== null) {
            $query->whereExists(function ($sub) use ($doctorId, $clientId) {
                $sub->select(DB::raw(1))
                    ->from('client_users AS cu')
                    ->where('cu.id_user', $doctorId)
                    ->where('cu.id_client', $clientId)
                    ->whereRaw('cu.id_user = s.id_doctor');
            });
        }

        // Filtros por clínica y rango de fechas
        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

    // Se obtienen todas las citas de una secretaria, pudiendose filtrar por doctor, clínica y rango de fechas.
    public function getAppointmentsForSecretary(
        int $clientId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = $this->baseQuery()
            // Solo doctores (role = 1) que pertenezcan al mismo cliente
            ->join('client_users AS cu', function ($join) use ($clientId) {
                $join->on('cu.id_user', '=', 's.id_doctor')
                    ->where('cu.id_client', '=', $clientId)
                    ->where('cu.role', '=', 1);
            });

        // Filtro por doctor
        if ($doctorId !== null) {
            $query->where('s.id_doctor', $doctorId);
        }

        // Filtros por clínica y rango de fechas
        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

    // Se obtienen todas las citas de un paciente, pudiendose filtrar por doctor, clínica y rango de fechas.
    public function getAppointmentsForPatient(
        int $patientId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = $this->baseQuery()
            ->where('a.id_patient', $patientId)
            // El paciente solo ve citas aceptadas o solicitadas
            ->whereIn('a.status', ['accepted', 'requested']);

        // Filtro por doctor
        if ($doctorId !== null) {
            $query->where('s.id_doctor', $doctorId);
        }

        // Filtros por clínica y rango de fechas
        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    // Filtros compartidos entre los tres calendarios.
    private function applyCommonFilters(
        &$query,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): void {
        if ($clinicId !== null) {
            $query->where('s.id_clinic', $clinicId);
        }
        if ($dateFrom !== null) {
            $query->where('a.date', '>=', $dateFrom);
        }
        if ($dateTo !== null) {
            $query->where('a.date', '<=', $dateTo);
        }
    }
}