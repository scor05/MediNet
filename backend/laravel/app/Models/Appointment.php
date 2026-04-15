<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    protected $fillable = [
        'id_schedule',
        'id_patient',
        'name_patient',
        'date',
        'status',
        'start_time',
        'created_by',
        'updated_by',
    ];

    // Definición de las relaciones
    public function schedule()
    {
        return $this->belongsTo(Schedule::class, 'id_schedule');
    }

    public function patient()
    {
        return $this->belongsTo(User::class, 'id_patient');
    }
}
