<?php

use App\Http\Controllers\PublicController;
use Illuminate\Support\Facades\Route;

Route::prefix('public')->group(function () {
    Route::get('/doctors', [PublicController::class, 'doctors'])
        ->middleware('throttle:public-search');
    Route::get('/clinics', [PublicController::class, 'clinics'])
        ->middleware('throttle:public-search');
    Route::get('/slots', [PublicController::class, 'slots'])
        ->middleware('throttle:public-slots');
    Route::post('/appointments', [PublicController::class, 'appointments'])
        ->middleware('throttle:creation');
});
