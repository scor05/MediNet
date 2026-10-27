<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\NotificationPreferenceController;

Route::prefix('notification-preferences')->group(function () {
    Route::get('/', [NotificationPreferenceController::class, 'index']);
    Route::put('/', [NotificationPreferenceController::class, 'update']);
    Route::delete('/', [NotificationPreferenceController::class, 'destroy']);
});
