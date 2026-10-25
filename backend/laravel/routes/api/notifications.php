<?php

use App\Http\Controllers\NotificationController;
use Illuminate\Support\Facades\Route;

Route::prefix('notifications')->group(function () {
    Route::get('/', [NotificationController::class, 'index']);
    Route::get('/user/{userId}', [NotificationController::class, 'indexByUser']);
    Route::get('/{id}', [NotificationController::class, 'show']);
    Route::post('/', [NotificationController::class, 'store'])
        ->middleware('throttle:creation');
    Route::delete('/{id}', [NotificationController::class, 'destroy']);
});
