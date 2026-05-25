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
                'a.id_patient',
                'a.date',
                'a.start_time',
                'a.status',
                'a.created_at',
                'a.created_by',
                'a.updated_at',
                'a.updated_by',
                'doctor.id    AS doctor_id',
                'doctor.name  AS doctor_name',
                'cl.id        AS clinic_id',
                'cl.name      AS clinic_name',
                's.duration   AS appointment_duration',
                DB::raw('COALESCE(patient.name, a.name_patient) AS patient_name'),
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
        int $secretaryId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
        ?string $status = null,
    ): array {
        $query = $this->baseQuery()
            // Doctores (role = 1) del cliente
            ->join('client_users AS cu', function ($join) {
                $join->on('cu.id_user', '=', 's.id_doctor')
                    ->where('cu.role', '=', 1)
                    ->where('cu.is_active', '=', true);
            })
            // Secretaria (role = 2) del mismo cliente
            ->join('client_users AS cu_sec', function ($join) use ($secretaryId) {
                $join->on('cu_sec.id_client', '=', 'cu.id_client')
                    ->where('cu_sec.id_user', '=', $secretaryId)
                    ->where('cu_sec.role', '=', 2)
                    ->where('cu_sec.is_active', '=', true);
            });

        if ($doctorId !== null) {
            $query->where('s.id_doctor', $doctorId);
        }

        if ($status !== null) {
            $query->where('a.status', $status);
        }

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

    // Se obtienen citas ocupadas para el calendario público.
    public function getPublicAppointments(
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = $this->baseQuery()
            ->whereIn('a.status', ['accepted', 'requested']);

        if ($doctorId !== null) {
            $query->where('s.id_doctor', $doctorId);
        }

        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

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

    // Se obtienen los bloqueos de un conjunto de schedules en un rango de fechas
    public function getBlockadesForScheduleIds(
        array $scheduleIds,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = DB::table('schedule_blockades AS sb')
            ->join('schedules AS s', 's.id', '=', 'sb.id_schedule')
            ->join('users AS doctor', 'doctor.id', '=', 's.id_doctor')
            ->join('clinics AS cl', 'cl.id', '=', 's.id_clinic')
            ->select([
                'sb.id',
                'sb.id_schedule',
                'sb.date',
                'sb.start_time',
                'sb.end_time',
                'doctor.id   AS doctor_id',
                'doctor.name AS doctor_name',
                'cl.id       AS clinic_id',
                'cl.name     AS clinic_name',
                's.duration  AS appointment_duration',
            ])
            ->whereIn('sb.id_schedule', $scheduleIds);

        if ($dateFrom !== null) {
            $query->where('sb.date', '>=', $dateFrom);
        }
        if ($dateTo !== null) {
            $query->where('sb.date', '<=', $dateTo);
        }

        return $query->orderBy('sb.date')->orderBy('sb.start_time')->get()->toArray();
    }
}
