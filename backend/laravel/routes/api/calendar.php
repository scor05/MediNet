<?php

use App\Http\Controllers\CalendarController;

// Todas las rutas requieren autenticación
Route::middleware('auth.supabase')->prefix('calendar')->group(function () {

    Route::get('/doctor',    [CalendarController::class, 'doctor'])
        ->middleware('role:doctor');

    Route::get('/secretary', [CalendarController::class, 'secretary'])
        ->middleware('role:secretary');

    Route::get('/patient',   [CalendarController::class, 'patient'])
        ->middleware('role:patient');
});