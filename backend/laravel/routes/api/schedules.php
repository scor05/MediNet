<?php

use App\Http\Controllers\ScheduleController;
use Illuminate\Support\Facades\Route;

Route::prefix('schedules')->group(function () {
    Route::get('/secretary', [ScheduleController::class, 'indexForSecretary']);
    Route::get('/doctor/{doctorId}', [ScheduleController::class, 'indexByDoctor']);
    Route::get('/{id}', [ScheduleController::class, 'show']);
    Route::post('/', [ScheduleController::class, 'store'])
        ->middleware('throttle:creation');
    Route::put('/{id}', [ScheduleController::class, 'update']);
    Route::delete('/{id}', [ScheduleController::class, 'destroy']);
});
