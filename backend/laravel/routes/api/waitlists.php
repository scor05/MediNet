<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\WaitlistController;

Route::prefix('waitlists')->group(function () {
    Route::get('/', [WaitlistController::class, 'index']);
    Route::post('/', [WaitlistController::class, 'store']);
    Route::get('/patient/{patientId}', [WaitlistController::class, 'indexByPatient']);
    Route::get('/{id}', [WaitlistController::class, 'show']);
    Route::patch('/{id}', [WaitlistController::class, 'update']);
    Route::delete('/{id}', [WaitlistController::class, 'destroy']);
});
