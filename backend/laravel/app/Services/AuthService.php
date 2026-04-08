<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class AuthService
{
    protected $url;
    protected $anonKey;

    public function __construct()
    {
        $this->url = config('supabase.url');
        $this->anonKey = config('supabase.anon_key');
    }

    // Obtener usuario desde token
    public function getUser($token)
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $token,
            'apikey' => $this->anonKey,
        ])->get($this->url . '/auth/v1/user');

        if ($response->successful()) {
            return $response->json();
        }

        return null;
    }

    // Crear un nuevo usuario en Supabase Auth
    public function createUser(string $email, string $password): ?array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . config('supabase.service_role_key'),
            'apikey' => config('supabase.service_role_key'),
        ])->post($this->url . '/auth/v1/admin/users', [
                    'email' => $email,
                    'password' => $password,
                    'email_confirm' => true,
                ]);

        return $response->successful() ? $response->json() : null;
    }

    // Iniciar sesión en Supabase Auth para obtener un token
    public function signIn(string $email, string $password): ?array
    {
        $response = Http::withHeaders([
            'apikey' => $this->anonKey,
            'Content-Type' => 'application/json',
        ])->post($this->url . '/auth/v1/token?grant_type=password', [
                    'email' => $email,
                    'password' => $password,
                ]);

        return $response->successful() ? $response->json() : null;
    }
}