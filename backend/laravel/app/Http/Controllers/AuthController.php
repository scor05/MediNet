<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\SupabaseAuthService;
use App\Services\UserService;

class AuthController extends Controller
{
    public function __construct(
        private SupabaseAuthService $supabaseService,
        private UserService $userService
    ) {
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone'    => 'nullable|string|max:20',
        ]);

        try {
            // Crear en Supabase Auth (con email_confirm: true para no necesitar confirmación)
            $supabaseUser = $this->supabaseService->createUser(
                $validated['email'],
                $validated['password']
            );

            if (!$supabaseUser) {
                return response()->json(['message' => 'Error al crear usuario en Supabase. Intenta de nuevo.'], 500);
            }

            // Crear en tabla users local
            $localUser = $this->userService->create([
                'name'  => $validated['name'],
                'email' => $validated['email'],
                'phone' => $validated['phone'] ?? null,
            ]);

            return response()->json($localUser, 201);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Error interno al registrar usuario.'], 500);
        }
    }
}
