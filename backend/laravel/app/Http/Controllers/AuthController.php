<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\AuthService;
use App\Services\UserService;

class AuthController extends Controller
{
    public function __construct(
        private AuthService $authService,
        private UserService $userService
    ) {
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:20',
        ]);

        try {
            // Crear en Supabase Auth
            $supabaseUser = $this->authService->createUser(
                $validated['email'],
                $validated['password']
            );

            if (!$supabaseUser) {
                return response()->json(['message' => 'Error al crear usuario en Supabase. Intenta de nuevo.'], 500);
            }

            // Crear en tabla users local
            $localUser = $this->userService->create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'phone' => $validated['phone'] ?? null,
            ]);

            // Hacer sign in para obtener el token
            $session = $this->authService->signIn(
                $validated['email'],
                $validated['password']
            );

            if (!$session) {
                return response()->json(['message' => 'Usuario creado pero no se pudo iniciar sesión.'], 500);
            }

            return response()->json($session, 201);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error interno al registrar usuario.',
                'debug' => $e->getMessage(),
            ], 500);
        }
    }
}
