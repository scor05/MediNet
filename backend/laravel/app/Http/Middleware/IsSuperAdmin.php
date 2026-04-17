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
        $localUser = $request->getUserResolver()();

        if (!$localUser) {
            return response()->json([
                'message' => 'Usuario no autenticado'
            ], 401);
        }

        // Verificar si el usuario existe en la tabla superadmins
        $isSuperAdmin = SuperAdmin::where('id_user', $localUser->id)->exists();

        if (!$isSuperAdmin) {
            return response()->json([
                'message' => 'Acceso denegado. Se requiere ser superadmin'
            ], 403);
        }

        return $next($request);
    }
}