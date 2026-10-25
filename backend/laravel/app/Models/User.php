<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'name',
        'email',
        'phone',
        'fcm_token',
        'is_active',
    ];

    // Columnas que deben ser convertidas a boolean
    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Nunca exponer tokens de dispositivos al serializar un usuario.
    protected $hidden = [
        'fcm_token',
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
