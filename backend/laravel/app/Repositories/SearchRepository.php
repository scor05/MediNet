<?php

namespace App\Repositories;

use Illuminate\Support\Facades\DB;

class SearchRepository
{
    public function searchDoctors(string $query)
    {
        $search = '%' . $query . '%';

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
            ->where('users.name', 'ILIKE', $search)
            ->where('cu.role', 1)
            ->where('cu.is_active', true)
            ->select(
                'users.id',
                'users.name',
                DB::raw("COALESCE(specialties.specialty, 'Sin especialidad') as specialty")
            )
            ->distinct()
            ->get();
    }

    public function searchClinics(string $query)
    {
        $search = '%' . $query . '%';

        return DB::table('clinics')
            ->where('name', 'ILIKE', $search)
            ->select(
                'id',
                'name',
                'address'
            )
            ->get();
    }
}