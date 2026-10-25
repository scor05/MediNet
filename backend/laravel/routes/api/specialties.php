<?php

use App\Http\Controllers\SpecialtyController;
use Illuminate\Support\Facades\Route;

Route::prefix('specialties')->group(function () {
    Route::get('/', [SpecialtyController::class, 'index']);
    Route::get('/{specialtyId}', [SpecialtyController::class, 'show']);
    Route::post('/', [SpecialtyController::class, 'store'])
        ->middleware('throttle:creation');
    Route::patch('/{specialtyId}', [SpecialtyController::class, 'update']);
    Route::delete('/{specialtyId}', [SpecialtyController::class, 'destroy']);
});
