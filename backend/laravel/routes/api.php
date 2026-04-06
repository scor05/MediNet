<?php

require __DIR__ . '/api/clients.php';
require __DIR__ . '/api/specialties.php';
require __DIR__ . '/api/users.php';
require __DIR__ . '/api/clinics.php';

use Illuminate\Http\Request;
use App\Services\SupabaseAuthService;

Route::get('/user', function (Request $request) {

    $token = $request->bearerToken();

    if (!$token) {
        return response()->json([
            'error' => 'Token no proporcionado'
        ], 401);
    }

    $authService = new SupabaseAuthService();
    $user = $authService->getUser($token);

    if (!$user) {
        return response()->json([
            'error' => 'Token inválido o expirado'
        ], 401);
    }

    return response()->json($user);
});