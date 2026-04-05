<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\SpecialtyController;

Route::prefix('specialties')->group(function () {
    Route::get('/', [SpecialtyController::class, 'index']);
    Route::get('/{specialtyId}', [SpecialtyController::class, 'show']);
    Route::post('/', [SpecialtyController::class, 'store']);
    Route::patch('/{specialtyId}', [SpecialtyController::class, 'update']);
    Route::delete('/{specialtyId}', [SpecialtyController::class, 'destroy']);
});