<?php

namespace App\Models;

use App\Models\ClientUser;
use App\Models\DoctorSpecialty;

class User extends BaseModel
{
    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'name',
        'email',
        'phone',
        'is_active',
    ];

    // Columnas que deben ser convertidas a boolean
    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function clientUsers()
    {
        return $this->hasMany(ClientUser::class, 'id_user');
    }

    public function doctorSpecialties()
    {
        return $this->hasMany(DoctorSpecialty::class, 'id_doctor');
    }
}
