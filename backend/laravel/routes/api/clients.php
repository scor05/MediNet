<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ClientController;
use App\Http\Controllers\ClientUserController;
use App\Http\Controllers\ClientClinicController;

Route::prefix('clients')->group(function () {
    Route::get('/', [ClientController::class, 'index']);
    Route::get('/{clientId}', [ClientController::class, 'show']);
    Route::post('/', [ClientController::class, 'store']);
    Route::patch('/{clientId}', [ClientController::class, 'update']);
    Route::delete('/{clientId}', [ClientController::class, 'destroy']);

    Route::get('/{clientId}/users', [ClientUserController::class, 'index']);
    Route::post('/{clientId}/users', [ClientUserController::class, 'store']);
    Route::patch('/{clientId}/users/{userId}', [ClientUserController::class, 'update']);
    Route::delete('/{clientId}/users/{userId}', [ClientUserController::class, 'destroy']);

    Route::get('/{clientId}/clinics', [ClientClinicController::class, 'index']);
    Route::post('/{clientId}/clinics', [ClientClinicController::class, 'store']);
    Route::patch('/{clientId}/clinics/{clinicId}', [ClientClinicController::class, 'update']);
    Route::delete('/{clientId}/clinics/{clinicId}', [ClientClinicController::class, 'destroy']);
});