<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ClientUserController;
use App\Http\Controllers\ClientClinicController;

Route::prefix('clients')->group(function () {
    Route::get('/{clientId}/users', [ClientUserController::class, 'index']);
    Route::post('/{clientId}/users', [ClientUserController::class, 'store']);
    Route::put('/{clientId}/users/{userId}', [ClientUserController::class, 'update']);
    Route::delete('/{clientId}/users/{userId}', [ClientUserController::class, 'destroy']);

    Route::get('/{clientId}/clinics', [ClientClinicController::class, 'index']);
    Route::post('/{clientId}/clinics', [ClientClinicController::class, 'store']);
    Route::put('/{clientId}/clinics/{clinicId}', [ClientClinicController::class, 'update']);
    Route::delete('/{clientId}/clinics/{clinicId}', [ClientClinicController::class, 'destroy']);
});