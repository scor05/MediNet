<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\NotificationController;

Route::prefix('notifications')->group(function () {
    Route::get('/', [NotificationController::class, 'index']);
    Route::get('/user/{userId}', [NotificationController::class, 'indexByUser']);
    Route::get('/{id}', [NotificationController::class, 'show']);
    Route::post('/', [NotificationController::class, 'store']);
    Route::delete('/{id}', [NotificationController::class, 'destroy']);
});
