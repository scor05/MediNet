<?php

namespace App\Models;

class Specialty extends BaseModel
{
    // Se desactivan los timestamps porque esta tabla no los usa
    public $timestamps = false;

    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'specialty',
    ];
}
