<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

//Ruta pública
Route::get('/public', function () {
    return response()->json([
        'message' => 'Ruta publica funcionando'
    ]);
});

//Todo protegido por Supabase Auth
Route::middleware('supabase.auth')->group(function () {


    require __DIR__ . '/api/clients.php';
    require __DIR__ . '/api/specialties.php';
    require __DIR__ . '/api/users.php';
    require __DIR__ . '/api/clinics.php';
    require __DIR__ . '/api/appointments.php';

    //Usuario autenticado
    Route::get('/user', function (Request $request) {
        return response()->json([
            'message' => 'Token válido',
            'user' => $request->attributes->get('supabase_user')
        ]);
    });

    //Solo DOCTOR
    Route::get('/doctor-only', function (Request $request) {
        return response()->json([
            'message' => 'Acceso permitido solo para DOCTOR'
        ]);
    })->middleware('role:doctor');

    //Solo SECRETARY
    Route::get('/secretary-only', function (Request $request) {
        return response()->json([
            'message' => 'Acceso permitido solo para SECRETARY'
        ]);
    })->middleware('role:secretary');

});