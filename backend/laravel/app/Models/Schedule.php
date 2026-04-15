<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Schedule extends Model
{
    protected $table = 'schedules';

    protected $fillable = [
        'id_doctor',
        'id_clinic',
        'day_of_week',
        'start_time',
        'end_time',
        'is_active',
        'duration',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}
