<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    protected $table = 'appointments';

    protected $fillable = [
        'id_schedule',
        'id_patient',
        'date',
        'status',
        'start_time',
        'created_by',
        'updated_by',
    ];
}
