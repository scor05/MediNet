<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PatientProfileController;

Route::prefix('patient')->group(function () {
    Route::get('/profile', [PatientProfileController::class, 'show']);
    Route::put('/profile', [PatientProfileController::class, 'update']);
});
