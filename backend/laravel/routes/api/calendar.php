<?php

use App\Http\Controllers\CalendarController;

Route::prefix('calendar')->group(function () {
    Route::get('/doctor', [CalendarController::class, 'doctor']);
    Route::get('/secretary', [CalendarController::class, 'secretary']);
    Route::get('/patient', [CalendarController::class, 'patient']);
});