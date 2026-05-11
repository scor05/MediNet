<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Services\AuthService;
use App\Models\User;
use Illuminate\Support\Facades\Log;

class SupabaseAuth
{
    // Se inyecta el servicio
    public function __construct(private AuthService $authService)
    {
    }

    public function handle(Request $request, Closure $next): Response
    {
        $isSearchRequest = $request->is('api/search');
        $totalStart = microtime(true);

        if ($isSearchRequest) {
            Log::debug('search.middleware.start', [
                'path' => $request->path(),
                'method' => $request->method(),
                'query_length' => strlen((string) $request->query('q', '')),
            ]);
        }

        // Extraer el token del header
        $tokenStart = microtime(true);
        $token = $request->bearerToken();

        if ($isSearchRequest) {
            Log::debug('search.middleware.token_extracted', [
                'elapsed_ms' => $this->elapsedMs($tokenStart),
                'has_token' => $token !== null,
            ]);
        }

        if (!$token) {
            if ($isSearchRequest) {
                Log::debug('search.middleware.finished', [
                    'elapsed_ms' => $this->elapsedMs($totalStart),
                    'status' => 401,
                    'reason' => 'missing_token',
                ]);
            }

            return response()->json([
                'message' => 'Token no proporcionado'
            ], 401);
        }

        // Verificar el token con Supabase
        $supabaseStart = microtime(true);
        try {
            $supabaseUser = $this->authService->getUser($token);
        } catch (\Throwable $e) {
            if ($isSearchRequest) {
                Log::debug('search.middleware.supabase_validation_failed', [
                    'elapsed_ms' => $this->elapsedMs($supabaseStart),
                    'total_elapsed_ms' => $this->elapsedMs($totalStart),
                    'exception' => $e->getMessage(),
                ]);
            }

            return response()->json([
                'message' => 'No se pudo validar el token en este momento'
            ], 500);
        }

        if ($isSearchRequest) {
            Log::debug('search.middleware.supabase_validated', [
                'elapsed_ms' => $this->elapsedMs($supabaseStart),
                'has_supabase_user' => (bool) $supabaseUser,
            ]);
        }

        if (!$supabaseUser) {
            if ($isSearchRequest) {
                Log::debug('search.middleware.finished', [
                    'elapsed_ms' => $this->elapsedMs($totalStart),
                    'status' => 401,
                    'reason' => 'invalid_token',
                ]);
            }

            return response()->json([
                'message' => 'Token invÃ¡lido o expirado'
            ], 401);
        }

        // Buscar el usuario local en tabla users usando el email
        $email = $supabaseUser['email'] ?? null;

        if (!$email) {
            if ($isSearchRequest) {
                Log::debug('search.middleware.finished', [
                    'elapsed_ms' => $this->elapsedMs($totalStart),
                    'status' => 401,
                    'reason' => 'missing_email',
                ]);
            }

            return response()->json([
                'message' => 'No se pudo identificar el usuario autenticado'
            ], 401);
        }

        $localUserStart = microtime(true);
        $localUser = User::where('email', $email)->first();

        if ($isSearchRequest) {
            Log::debug('search.middleware.local_user_lookup', [
                'elapsed_ms' => $this->elapsedMs($localUserStart),
                'found' => $localUser !== null,
            ]);
        }

        if (!$localUser) {
            if ($isSearchRequest) {
                Log::debug('search.middleware.finished', [
                    'elapsed_ms' => $this->elapsedMs($totalStart),
                    'status' => 403,
                    'reason' => 'local_user_not_found',
                ]);
            }

            return response()->json([
                'message' => 'Usuario no registrado en el sistema'
            ], 403);
        }

        // Pasar el usuario de supabase en el request para que los controllers lo use
        $request->attributes->set('supabase_user', $supabaseUser);

        // Vincular el usuario local directamente al request
        $request->setUserResolver(fn() => $localUser);

        $nextStart = microtime(true);
        $response = $next($request);

        if ($isSearchRequest) {
            Log::debug('search.middleware.next_completed', [
                'elapsed_ms' => $this->elapsedMs($nextStart),
                'status' => $response->getStatusCode(),
            ]);
            Log::debug('search.middleware.finished', [
                'elapsed_ms' => $this->elapsedMs($totalStart),
                'status' => $response->getStatusCode(),
            ]);
        }

        return $response;
    }

    private function elapsedMs(float $start): float
    {
        return round((microtime(true) - $start) * 1000, 2);
    }
}
