<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Specialty extends Model
{
    // Se desactivan los timestamps porque esta tabla no los usa
    public $timestamps = false;

    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'specialty',
    ];
}
