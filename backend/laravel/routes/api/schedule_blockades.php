<?php

use App\Http\Controllers\ScheduleBlockadeController;
use Illuminate\Support\Facades\Route;

Route::prefix('schedule-blockades')->group(function () {
    Route::get('/', [ScheduleBlockadeController::class, 'index']);
    Route::post('/', [ScheduleBlockadeController::class, 'store'])
        ->middleware('throttle:creation');
    Route::delete('/{id}', [ScheduleBlockadeController::class, 'destroy']);
});
