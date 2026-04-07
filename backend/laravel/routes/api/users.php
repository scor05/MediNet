<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DoctorSpecialtyController;
use App\Http\Controllers\UserController;

Route::prefix('users')->group(function () {
    Route::get('/', [UserController::class, 'index']);
    Route::get('/{id}', [UserController::class, 'show']);
    Route::patch('/{id}', [UserController::class, 'update']);
    Route::delete('/{id}', [UserController::class, 'destroy']);

    Route::get('/{doctorId}/specialties', [DoctorSpecialtyController::class, 'index']);
    Route::post('/{doctorId}/specialties', [DoctorSpecialtyController::class, 'store']);
    Route::delete('/{doctorId}/specialties/{specialtyId}', [DoctorSpecialtyController::class, 'destroy']);
});