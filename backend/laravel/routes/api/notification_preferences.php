<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\NotificationPreferenceController;

Route::prefix('notification-preferences')->group(function () {
    Route::get('/{userId}', [NotificationPreferenceController::class, 'index']);
    Route::put('/{userId}', [NotificationPreferenceController::class, 'update']);
    Route::delete('/{userId}', [NotificationPreferenceController::class, 'destroy']);
});
