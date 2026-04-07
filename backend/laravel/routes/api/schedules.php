<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ScheduleController;

Route::prefix('schedules')->group(function () {
    Route::get('/',        [ScheduleController::class, 'index']);
    Route::get('/{id}',    [ScheduleController::class, 'show']);
    Route::post('/',       [ScheduleController::class, 'store']);
    Route::put('/{id}',    [ScheduleController::class, 'update']);
    Route::delete('/{id}', [ScheduleController::class, 'destroy']);
});

Route::prefix('users')->group(function () {
    Route::get('/{doctorId}/schedules', [ScheduleController::class, 'indexByDoctor']);
});