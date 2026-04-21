<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ClientController;
use App\Http\Controllers\ClientUserController;
use App\Http\Controllers\ClinicController;

Route::prefix('clients')->group(function () {
    Route::middleware('is.superadmin')->group(function () {
        Route::get('/', [ClientController::class, 'index']);
        Route::get('/{clientId}', [ClientController::class, 'show']);
        Route::post('/', [ClientController::class, 'store']);
        Route::patch('/{clientId}', [ClientController::class, 'update']);
        Route::delete('/{clientId}', [ClientController::class, 'destroy']);
    });

    Route::get('/{clientId}/summary', [ClientController::class, 'summary']);
    Route::get('/{clientId}/users', [ClientUserController::class, 'index']);
    Route::post('/{clientId}/users', [ClientUserController::class, 'store']);
    Route::patch('/{clientId}/users/{userId}', [ClientUserController::class, 'update']);
    Route::delete('/{clientId}/users/{userId}', [ClientUserController::class, 'destroy']);

    Route::get('/{clientId}/clinics', [ClinicController::class, 'index']);
    Route::post('/{clientId}/clinics', [ClinicController::class, 'store']);
    Route::patch('/{clientId}/clinics/{clinicId}', [ClinicController::class, 'update']);
    Route::delete('/{clientId}/clinics/{clinicId}', [ClinicController::class, 'destroy']);
});
