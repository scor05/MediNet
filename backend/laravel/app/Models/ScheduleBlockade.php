<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ScheduleBlockade extends Model
{
    // La tabla no usa timestamps automáticos
    public $timestamps = false;

    protected $fillable = [
        'id_schedule',
        'date',
        'start_time',
        'end_time',
    ];

    // Relación con el horario bloqueado
    public function schedule()
    {
        return $this->belongsTo(Schedule::class, 'id_schedule');
    }
}
