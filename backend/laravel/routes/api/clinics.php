<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ClinicController;

Route::prefix('clinics')->group(function () {
    Route::get('/',        [ClinicController::class, 'index']);
    Route::get('/{id}',    [ClinicController::class, 'show']);
    Route::post('/',       [ClinicController::class, 'store']);
    Route::patch('/{id}',  [ClinicController::class, 'update']);
    Route::delete('/{id}', [ClinicController::class, 'destroy']);
});