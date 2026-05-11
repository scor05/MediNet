<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SearchRepository
{
    public function searchDoctors(string $query)
    {
        $totalStart = microtime(true);
        $search = '%' . $query . '%';

        Log::debug('search.repository.doctors.start', [
            'query_length' => strlen($query),
        ]);

        $queryBuildStart = microtime(true);
        $builder = DB::table('users')
            ->join('client_users AS cu', 'cu.id_user', '=', 'users.id')
            ->leftJoin(
                'doctor_specialties',
                'users.id',
                '=',
                'doctor_specialties.id_doctor'
            )
            ->leftJoin(
                'specialties',
                'doctor_specialties.id_specialty',
                '=',
                'specialties.id'
            )
            ->where('users.name', 'ILIKE', $search)
            ->where('cu.role', 1)
            ->where('cu.is_active', true)
            ->select(
                'users.id',
                'users.name',
                DB::raw("COALESCE(specialties.specialty, 'Sin especialidad') as specialty")
            )
            ->distinct();

        Log::debug('search.repository.doctors.query_built', [
            'elapsed_ms' => $this->elapsedMs($queryBuildStart),
        ]);

        $dbStart = microtime(true);
        $results = $builder->get();

        Log::debug('search.repository.doctors.db_completed', [
            'elapsed_ms' => $this->elapsedMs($dbStart),
            'count' => count($results),
        ]);
        Log::debug('search.repository.doctors.finished', [
            'elapsed_ms' => $this->elapsedMs($totalStart),
        ]);

        return $results;
    }

    public function searchClinics(string $query)
    {
        $totalStart = microtime(true);
        $search = '%' . $query . '%';

        Log::debug('search.repository.clinics.start', [
            'query_length' => strlen($query),
        ]);

        $queryBuildStart = microtime(true);
        $builder = DB::table('clinics')
            ->where('name', 'ILIKE', $search)
            ->select(
                'id',
                'name',
                'address'
            );

        Log::debug('search.repository.clinics.query_built', [
            'elapsed_ms' => $this->elapsedMs($queryBuildStart),
        ]);

        $dbStart = microtime(true);
        $results = $builder->get();

        Log::debug('search.repository.clinics.db_completed', [
            'elapsed_ms' => $this->elapsedMs($dbStart),
            'count' => count($results),
        ]);
        Log::debug('search.repository.clinics.finished', [
            'elapsed_ms' => $this->elapsedMs($totalStart),
        ]);

        return $results;
    }

    private function elapsedMs(float $start): float
    {
        return round((microtime(true) - $start) * 1000, 2);
    }
}
