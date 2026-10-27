<?php

namespace App\Http\Middleware;

use App\Models\ClientUser;
use App\Models\Superadmin;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class IsClientAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json([
                'message' => 'Usuario no autenticado',
            ], 401);
        }

        if (Superadmin::where('id_user', $user->id)->exists()) {
            return $next($request);
        }

        $clientId = $request->route('clientId');
        $isClientAdmin = $clientId !== null && ClientUser::query()
            ->where('id_client', $clientId)
            ->where('id_user', $user->id)
            ->where('is_admin', true)
            ->where('is_active', true)
            ->exists();

        if (! $isClientAdmin) {
            return response()->json([
                'message' => 'Acceso denegado. No es administrador activo de esta organización.',
            ], 403);
        }

        return $next($request);
    }
}
