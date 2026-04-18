<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Superadmin extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'id_user',
    ];

    // Definición de relaciones
    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}