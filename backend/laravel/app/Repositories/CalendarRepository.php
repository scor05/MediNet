<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class CalendarRepository
{
    // -------------------------------------------------------------------------
    // Shared base query
    // -------------------------------------------------------------------------

    /**
     * Base query que une appointments → schedules → clinics → users (doctor y patient).
     * Devuelve un QueryBuilder al que se le pueden encadenar más filtros.
     */
    private function baseQuery()
    {
        return DB::table('appointments AS a')
            ->join('schedules AS s',       's.id',       '=', 'a.id_schedule')
            ->join('clinics AS cl',        'cl.id',      '=', 's.id_clinic')
            ->join('users AS doctor',      'doctor.id',  '=', 's.id_doctor')
            ->join('users AS patient',     'patient.id', '=', 'a.id_patient')
            ->select([
                'a.id',
                'a.id_schedule',
                'a.date',
                'a.start_time',
                'a.status',
                'doctor.id   AS doctor_id',
                'doctor.name AS doctor_name',
                'patient.id   AS patient_id',
                'patient.name AS patient_name',
                'cl.id        AS clinic_id',
                'cl.name      AS clinic_name',
                'cl.address   AS clinic_address',
            ]);
    }

    // -------------------------------------------------------------------------
    // Doctor calendar  
    // -------------------------------------------------------------------------

    public function getAppointmentsForDoctor(
        int $doctorId,
        ?int $clientId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = $this->baseQuery()
            ->where('s.id_doctor', $doctorId);

        // Filtro por cliente: el doctor debe pertenecer a ese cliente
        if ($clientId !== null) {
            $query->whereExists(function ($sub) use ($doctorId, $clientId) {
                $sub->select(DB::raw(1))
                    ->from('client_users AS cu')
                    ->where('cu.id_user',   $doctorId)
                    ->where('cu.id_client', $clientId)
                    ->whereRaw('cu.id_user = s.id_doctor');
            });
        }

        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

    // -------------------------------------------------------------------------
    // Secretary calendar  
    // -------------------------------------------------------------------------

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
                $join->on('cu.id_user',   '=', 's.id_doctor')
                     ->where('cu.id_client', '=', $clientId)
                     ->where('cu.role',      '=', 1);   // 1 = doctor
            });

        if ($doctorId !== null) {
            $query->where('s.id_doctor', $doctorId);
        }

        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

    // -------------------------------------------------------------------------
    // Patient calendar  
    // -------------------------------------------------------------------------

    public function getAppointmentsForPatient(
        int $patientId,
        ?int $doctorId,
        ?int $clinicId,
        ?string $dateFrom,
        ?string $dateTo,
    ): array {
        $query = $this->baseQuery()
            ->where('a.id_patient', $patientId)
            // El paciente solo ve citas aceptadas
            ->whereIn('a.status', ['accepted', 'requested']);

        if ($doctorId !== null) {
            $query->where('s.id_doctor', $doctorId);
        }

        $this->applyCommonFilters($query, $clinicId, $dateFrom, $dateTo);

        return $query->orderBy('a.date')->orderBy('a.start_time')->get()->toArray();
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    /**
     * Retorna el client_id al que pertenece un usuario (cualquier rol).
     */
    public function getClientIdForUser(int $userId): ?int
    {
        $row = DB::table('client_users')
            ->where('id_user',   $userId)
            ->where('is_active', true)
            ->first(['id_client']);

        return $row?->id_client;
    }

    /**
     * Filtros compartidos entre los tres calendarios.
     */
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