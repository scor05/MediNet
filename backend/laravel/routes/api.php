<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
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
    Route::get('/user', function (Request $request) {
        return response()->json([
            'message' => 'Token válido',
            'user' => $request->user()
        ]);
    });
});