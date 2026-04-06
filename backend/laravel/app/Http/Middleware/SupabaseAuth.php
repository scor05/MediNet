<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Services\SupabaseAuthService;

class SupabaseAuth
{
    public function handle(Request $request, Closure $next): Response
    {
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

        $request->attributes->set('supabase_user', $user);

        return $next($request);
    }
}