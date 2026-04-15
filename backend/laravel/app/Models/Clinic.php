<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Clinic extends Model
{
    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'name',
        'address',
        'phone',
        'email',
    ];
}
