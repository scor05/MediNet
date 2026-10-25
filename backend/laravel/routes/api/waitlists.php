<?php

use App\Http\Controllers\WaitlistController;
use Illuminate\Support\Facades\Route;

Route::prefix('waitlists')->group(function () {

    Route::get(
        '/',
        [WaitlistController::class, 'index']
    );

    Route::post(
        '/',
        [WaitlistController::class, 'store']
    )->middleware('throttle:creation');

    Route::get(
        '/patient/{patientId}',
        [WaitlistController::class, 'indexByPatient']
    );

    Route::get(
        '/{id}',
        [WaitlistController::class, 'show']
    );

    Route::patch(
        '/{id}',
        [WaitlistController::class, 'update']
    );

    Route::post(
        '/{id}/backup',
        [WaitlistController::class, 'storeBackup']
    )->middleware('throttle:creation');

    Route::post(
        '/{id}/backup/decline',
        [WaitlistController::class, 'declineBackup']
    );

    Route::delete(
        '/{id}',
        [WaitlistController::class, 'destroy']
    );
});
