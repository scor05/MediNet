<?php

namespace App\Models;

class Client extends BaseModel
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
