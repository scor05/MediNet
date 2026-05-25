<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationPreference extends Model
{
    // La tabla no usa timestamps ni id autoincremental
    public $timestamps = false;
    public $incrementing = false;

    // Clave primaria compuesta
    protected $primaryKey = ['id_user', 'channel'];
    protected $keyType = 'array';

    protected $fillable = [
        'id_user',
        'channel',
    ];

    // Relación con el usuario dueño de la preferencia
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}
