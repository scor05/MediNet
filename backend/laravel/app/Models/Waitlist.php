<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Waitlist extends Model
{
    use HasFactory;

    protected $fillable = [
        'id_patient',
        'id_target_appointment',
        'id_fallback_appointment',
        'status',
    ];

    public function patient()
    {
        return $this->belongsTo(
            User::class,
            'id_patient'
        );
    }

    public function targetAppointment()
    {
        return $this->belongsTo(
            Appointment::class,
            'id_target_appointment'
        );
    }

    public function fallbackAppointment()
    {
        return $this->belongsTo(
            Appointment::class,
            'id_fallback_appointment'
        );
    }
}
