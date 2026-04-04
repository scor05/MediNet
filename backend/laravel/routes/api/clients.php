<?php

use App\Http\Controllers\ClientUserController;
use Illuminate\Support\Facades\Route;

Route::prefix('clients')->group(function () {
    Route::get('/{clientId}/users', [ClientUserController::class, 'index']);
    Route::post('/{clientId}/users', [ClientUserController::class, 'store']);
    Route::put('/{clientId}/users/{userId}', [ClientUserController::class, 'update']);
    Route::delete('/{clientId}/users/{userId}', [ClientUserController::class, 'destroy']);
});