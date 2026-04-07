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
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:20',
        ]);

        // Crear en Supabase Auth
        $supabaseUser = $this->supabaseService->createUser(
            $validated['email'],
            $validated['password']
        );

        if (!$supabaseUser) {
            return response()->json(['error' => 'Error al crear usuario en Supabase'], 500);
        }

        // Crear en tabla users local
        $localUser = $this->userService->create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? null,
        ]);

        return response()->json($localUser, 201);
    }
}
