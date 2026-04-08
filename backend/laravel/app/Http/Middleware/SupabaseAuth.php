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
                'error' => 'Token no proporcionado'
            ], 401);
        }

        // Verificar el token con Supabase
        $supabaseUser = $this->authService->getUser($token);

        if (!$supabaseUser) {
            return response()->json([
                'error' => 'Token inválido o expirado'
            ], 401);
        }

        // Buscar el usuario local en tabla users usando el email
        $localUser = User::where('email', $supabaseUser['email'])->first();

        if (!$localUser) {
            return response()->json([
                'error' => 'Usuario no registrado en el sistema'
            ], 403);
        }

        // Pasar el usuario de supabase en el request para que los controllers lo use
        $request->attributes->set('supabase_user', $supabaseUser);

        // Vincular el usuario local directamente al request (stateless, sin sesión)
        $request->setUserResolver(fn() => $localUser);

        return $next($request);
    }
}