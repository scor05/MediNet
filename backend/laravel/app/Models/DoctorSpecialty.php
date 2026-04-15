<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class DoctorSpecialty extends Model
{
    // Se desactiva el id autoincremental porque la llave primaria es compuesta
    public $incrementing = false;

    // Se desactivan los timestamps porque esta tabla no los usa
    public $timestamps = false;

    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'id_doctor',
        'id_specialty',
    ];

    // Definición de la llave primaria compuesta
    protected $primaryKey = ['id_doctor', 'id_specialty'];

    // Definición de las relaciones
    public function doctor()
    {
        return $this->belongsTo(User::class, 'id_doctor');
    }

    public function specialty()
    {
        return $this->belongsTo(Specialty::class, 'id_specialty');
    }
}
