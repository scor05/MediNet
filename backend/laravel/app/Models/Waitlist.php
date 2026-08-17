<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Waitlist extends Model
{
    protected $fillable = [
        'id_patient',
        'id_target_appointment',
        'id_fallback_appointment',
        'status',
    ];

    // Relación con el paciente
    public function patient()
    {
        return $this->belongsTo(User::class, 'id_patient');
    }

    // Relación con la cita objetivo (la que el paciente desea)
    public function targetAppointment()
    {
        return $this->belongsTo(Appointment::class, 'id_target_appointment');
    }

    // Relación con la cita de respaldo (la que el paciente tiene actualmente)
    public function fallbackAppointment()
    {
        return $this->belongsTo(Appointment::class, 'id_fallback_appointment');
    }
}
