<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $table = 'users';

    protected $fillable = [
        'name',
        'email',
        'password_hash',
        'phone',
        'is_active',
    ];

    protected $hidden = [
        'password_hash',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}