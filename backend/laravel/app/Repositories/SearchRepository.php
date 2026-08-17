<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class SearchRepository
{
    public function searchDoctors(string $query, int $limit = 16)
    {
        $search = '%'.$query.'%';

        return $this->doctorsQuery()
            ->where(function ($doctorQuery) use ($search) {
                $doctorQuery
                    ->where('users.name', 'ILIKE', $search)
                    ->orWhere('specialties.specialty', 'ILIKE', $search);
            })
            ->orderBy('users.name')
            ->limit($limit)
            ->get();
    }

    public function randomDoctors(int $limit = 16)
    {
        return $this->doctorsQuery()
            ->inRandomOrder()
            ->limit($limit)
            ->get();
    }

    public function searchClinics(string $query, int $limit = 16)
    {
        $search = '%'.$query.'%';

        return $this->clinicsQuery()
            ->where('name', 'ILIKE', $search)
            ->orderBy('name')
            ->limit($limit)
            ->get();
    }

    public function randomClinics(int $limit = 16)
    {
        return $this->clinicsQuery()
            ->inRandomOrder()
            ->limit($limit)
            ->get();
    }

    private function doctorsQuery()
    {
        return DB::table('users')
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
            ->where('cu.role', 1)
            ->where('cu.is_active', true)
            ->where('users.is_active', true)
            ->select(
                'users.id',
                'users.name',
                DB::raw("COALESCE(MIN(specialties.specialty), 'Sin especialidad') as specialty")
            )
            ->groupBy('users.id', 'users.name');
    }

    private function clinicsQuery()
    {
        return DB::table('clinics')
            ->where('is_active', true)
            ->select(
                'id',
                'name',
                'address'
            );
    }
}
