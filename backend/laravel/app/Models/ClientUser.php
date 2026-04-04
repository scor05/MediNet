<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClientUser extends Model
{
    // Se desactiva el id autoincremental porque la llave primaria es compuesta
    public $incrementing = false;

    // Se desactivan los timestamps porque esta tabla no los usa
    public $timestamps = false;

    // Columnas de la tabla en la base de datos
    protected $fillable = [
        'id_client',
        'id_user',
        'role',
        'is_admin',
        'is_active',
    ];

    // Definición de la llave primaria compuesta
    protected $primaryKey = ['id_client', 'id_user'];

    // Definición de las relaciones
    public function client()
    {
        return $this->belongsTo(Client::class, 'id_client');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}
