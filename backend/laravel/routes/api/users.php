<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DoctorSpecialtyController;

Route::prefix('users')->group(function () {
    Route::get('/{doctorId}/specialties', [DoctorSpecialtyController::class, 'index']);
    Route::post('/{doctorId}/specialties', [DoctorSpecialtyController::class, 'store']);
    Route::delete('/{doctorId}/specialties/{specialtyId}', [DoctorSpecialtyController::class, 'destroy']);
});