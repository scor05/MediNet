<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class SupabaseAuthService
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

}