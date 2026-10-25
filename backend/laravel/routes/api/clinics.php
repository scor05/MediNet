<?php

use App\Http\Controllers\ClinicController;
use Illuminate\Support\Facades\Route;

Route::prefix('clinics')->group(function () {
    Route::get('/', [ClinicController::class, 'index']);
    Route::get('/{id}', [ClinicController::class, 'show']);
    Route::post('/', [ClinicController::class, 'store'])
        ->middleware('throttle:creation');
    Route::patch('/{id}', [ClinicController::class, 'update']);
    Route::delete('/{id}', [ClinicController::class, 'destroy']);
});
