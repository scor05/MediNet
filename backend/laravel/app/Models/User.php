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
        'is_active',
    ];

    // Columnas que deben ser convertidas a boolean
    protected $casts = [
        'is_active' => 'boolean',
    ];
}