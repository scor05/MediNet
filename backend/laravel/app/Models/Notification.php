<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    // La tabla no usa timestamps automáticos (created_at/updated_at)
    public $timestamps = false;

    protected $fillable = [
        'id_user',
        'type',
        'message',
        'sent_at',
        'channel',
    ];

    // Conversión de tipos
    protected $casts = [
        'sent_at' => 'datetime',
    ];

    // Relación con el usuario destinatario
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}
