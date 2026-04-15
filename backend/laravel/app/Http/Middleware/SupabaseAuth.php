<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Services\AuthService;
use App\Models\User;

class SupabaseAuth
{
    // Se inyecta el servicio
    public function __construct(private AuthService $authService)
    {
    }

    public function handle(Request $request, Closure $next): Response
    {
        // Extraer el token del header
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'message' => 'Token no proporcionado'
            ], 401);
        }

        // Verificar el token con Supabase
        try {
            $supabaseUser = $this->authService->getUser($token);
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'No se pudo validar el token en este momento'
            ], 500);
        }

        if (!$supabaseUser) {
            return response()->json([
                'message' => 'Token inválido o expirado'
            ], 401);
        }

        // Buscar el usuario local en tabla users usando el email
        $email = $supabaseUser['email'] ?? null;

        if (!$email) {
            return response()->json([
                'message' => 'No se pudo identificar el usuario autenticado'
            ], 401);
        }

        $localUser = User::where('email', $email)->first();

        if (!$localUser) {
            return response()->json([
                'message' => 'Usuario no registrado en el sistema'
            ], 403);
        }

        // Pasar el usuario de supabase en el request para que los controllers lo use
        $request->attributes->set('supabase_user', $supabaseUser);

        // Vincular el usuario local directamente al request
        $request->setUserResolver(fn() => $localUser);

        return $next($request);
    }
}