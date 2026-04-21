<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Models\ClientUser;

class IsClientAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        // Obtener el usuario local del request (ya autenticado por SupabaseAuth)
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Usuario no autenticado'
            ], 401);
        }

        // Verificar si el usuario es admin de al menos un cliente activo
        $isClientAdmin = ClientUser::where('id_user', $user->id)
            ->where('is_admin', true)
            ->where('is_active', true)
            ->exists();

        if (!$isClientAdmin) {
            return response()->json([
                'message' => 'Acceso denegado. No es administrador de ningún cliente.'
            ], 403);
        }

        return $next($request);
    }
}