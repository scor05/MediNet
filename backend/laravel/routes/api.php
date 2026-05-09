<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\PublicCalendarController;
use App\Http\Controllers\PublicSlotController;

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
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);

    // Search 
    Route::get('/search', [SearchController::class, 'index']);

    // Calendar
    Route::get('/calendar/public', [PublicCalendarController::class, 'index']);

    // Slots
    Route::get('/public/slots', [PublicSlotController::class, 'index']);
});