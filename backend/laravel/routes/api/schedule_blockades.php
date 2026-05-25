<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ScheduleBlockadeController;

Route::prefix('schedule-blockades')->group(function () {
    Route::get('/', [ScheduleBlockadeController::class, 'index']);
    Route::post('/', [ScheduleBlockadeController::class, 'store']);
    Route::delete('/{id}', [ScheduleBlockadeController::class, 'destroy']);
});
