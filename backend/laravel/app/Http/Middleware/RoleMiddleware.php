<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $user = $request->attributes->get('supabase_user');

        if (!$user) {
            return response()->json([
                'error' => 'Usuario no autenticado'
            ], 401);
        }

        $userRole =
            $user['user_metadata']['role']
            ?? $user['app_metadata']['role']
            ?? null;

        if (!$userRole || !in_array($userRole, $roles)) {
            return response()->json([
                'error' => 'Acceso no autorizado para este rol'
            ], 403);
        }

        return $next($request);
    }
}