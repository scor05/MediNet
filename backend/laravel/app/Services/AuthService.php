<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use App\Exceptions\RegistrationException;

class AuthService
{
    protected $url;
    protected $anonKey;
    protected $serviceRoleKey;

    public function __construct(private UserService $userService)
    {
        $this->url = config('supabase.url');
        $this->anonKey = config('supabase.anon_key');
        $this->serviceRoleKey = config('supabase.service_role_key');
    }

    // Registrar a un usuario en Supabase Auth y en la db local
    public function register(array $data): array
    {
        // Crear usuario en Supabase Auth
        $this->createSupabaseUser($data['email'], $data['password']);

        // Crear usuario en tabla users local
        $this->userService->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
        ]);

        // Hacer sign in en Supabase Auth para obtener el token
        return $this->signIn($data['email'], $data['password']);
    }

    // Obtener usuario desde token
    public function getUser(string $token): ?array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'apikey' => $this->anonKey,
            ])->get($this->url . '/auth/v1/user');

            if ($response->successful()) {
                return $response->json();
            }

            if ($response->status() === 401 || $response->status() === 403) {
                return null;
            }

            throw new RegistrationException(
                'Error al validar el token.',
                500
            );
        } catch (\Throwable $e) {
            throw new RegistrationException(
                'No se pudo comunicar con el servidor para validar el token.',
                500
            );
        }
    }

    // Crear un nuevo usuario en Supabase Auth
    private function createSupabaseUser(string $email, string $password): array
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->serviceRoleKey,
                'apikey' => $this->serviceRoleKey,
            ])->post($this->url . '/auth/v1/admin/users', [
                        'email' => $email,
                        'password' => $password,
                        'email_confirm' => false,
                    ]);

            if ($response->successful()) {
                return $response->json();
            }

            throw new RegistrationException(
                'Error al crear usuario.',
                500
            );
        } catch (\Throwable $e) {
            throw new RegistrationException(
                'No se pudo comunicar con el servidor para crear el usuario.',
                500
            );
        }
    }

    // Iniciar sesión en Supabase Auth para obtener un token
    private function signIn(string $email, string $password): array
    {
        try {
            $response = Http::withHeaders([
                'apikey' => $this->anonKey,
                'Content-Type' => 'application/json',
            ])->post($this->url . '/auth/v1/token?grant_type=password', [
                        'email' => $email,
                        'password' => $password,
                    ]);

            if ($response->successful()) {
                return $response->json();
            }

            if ($response->status() === 400 || $response->status() === 401) {
                throw new RegistrationException(
                    'No se pudo iniciar sesión con el usuario recién creado.',
                    500
                );
            }

            throw new RegistrationException(
                'Error al iniciar sesión.',
                500
            );
        } catch (\Throwable $e) {
            throw new RegistrationException(
                'No se pudo comunicar con el servidor para iniciar sesión.',
                500
            );
        }
    }
}