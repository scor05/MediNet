<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SuperAdmin extends Model
{
    protected $table = 'superadmins';
    public $timestamps = false;

    protected $fillable = [
        'id_user',
    ];
}