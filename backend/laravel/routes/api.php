<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\AuthController;

// Rutas públicas
Route::post('/auth/register', [AuthController::class, 'register']);

// Rutas protegidas por autenticación
Route::middleware('supabase.auth')->group(function () {

    require __DIR__ . '/api/clients.php';
    require __DIR__ . '/api/specialties.php';
    require __DIR__ . '/api/users.php';
    require __DIR__ . '/api/clinics.php';
    require __DIR__ . '/api/schedules.php';
    require __DIR__ . '/api/appointments.php';
    require __DIR__ . '/api/calendar.php';

    // Usuario autenticado
    Route::get('/profile', [UserController::class, 'profile']);
});