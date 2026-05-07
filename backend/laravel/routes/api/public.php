<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PublicController;

Route::prefix('public')->group(function () {
    Route::get('/doctors', [PublicController::class, 'doctors']);
    Route::get('/clinics', [PublicController::class, 'clinics']);
    Route::get('/slots', [PublicController::class, 'slots']);
});
