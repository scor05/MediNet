<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Models\SuperAdmin;

class IsSuperAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        // Obtener el usuario local del request (ya autenticado por SupabaseAuth)
        $user = $request->user();

        if (!$user) {
            return response()->json(['message' => 'Usuario no autenticado'], 401);
        }

        // Verificar si el usuario existe en la tabla superadmins
        $isSuperadmin = Superadmin::where('id_user', $user->id)->exists();

        if (!$isSuperadmin) {
            return response()->json([
                'message' => 'Acceso denegado. No tiene los permisos necesarios.'
            ], 403);
        }

        return $next($request);
    }
}