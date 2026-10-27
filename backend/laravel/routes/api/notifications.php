<?php

use App\Http\Controllers\NotificationController;
use Illuminate\Support\Facades\Route;

Route::prefix('notifications')->group(function () {
    Route::get('/', [NotificationController::class, 'index']);
    Route::get('/{id}', [NotificationController::class, 'show']);
    Route::delete('/{id}', [NotificationController::class, 'destroy']);
});
