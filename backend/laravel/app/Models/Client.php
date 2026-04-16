<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Client extends Model
{
    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'nit',
        'name',
        'is_active',
    ];

    // Columnas que deben ser convertidas a boolean
    protected $casts = [
        'is_active' => 'boolean',
    ];
}
