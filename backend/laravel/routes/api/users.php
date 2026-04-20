<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DoctorSpecialtyController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ScheduleController;

Route::prefix('users')->group(function () {
    Route::get('/available/{clientId}', [UserController::class, 'availableForClient']);

    Route::get('/', [UserController::class, 'index']);
    Route::get('/{id}', [UserController::class, 'show'])->whereNumber('id');
    Route::patch('/{id}', [UserController::class, 'update'])->whereNumber('id');
    Route::delete('/{id}', [UserController::class, 'destroy'])->whereNumber('id');

    Route::get('/{doctorId}/specialties', [DoctorSpecialtyController::class, 'index'])->whereNumber('doctorId');
    Route::post('/{doctorId}/specialties', [DoctorSpecialtyController::class, 'store'])->whereNumber('doctorId');
    Route::delete('/{doctorId}/specialties/{specialtyId}', [DoctorSpecialtyController::class, 'destroy'])->whereNumber('doctorId')->whereNumber('specialtyId');

    Route::get('/{doctorId}/schedules', [ScheduleController::class, 'index']);
});