<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ClientClinic extends Model
{
    // Se desactiva el id autoincremental porque la llave primaria es compuesta
    public $incrementing = false;

    // Se desactivan los timestamps porque esta tabla no los usa
    public $timestamps = false;

    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'id_client',
        'id_clinic',
        'is_active',
    ];

    // Definición de la llave primaria compuesta
    protected $primaryKey = ['id_client', 'id_clinic'];

    // Columnas que deben ser convertidas a boolean
    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Definición de las relaciones
    public function client()
    {
        return $this->belongsTo(Client::class, 'id_client');
    }

    public function clinic()
    {
        return $this->belongsTo(Clinic::class, 'id_clinic');
    }
}
