<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SuperAdmin extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'id_user',
    ];
}