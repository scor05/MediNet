<?php

namespace App\Models;

class Clinic extends BaseModel
{
    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'name',
        'address',
        'phone',
        'email',
    ];
}
