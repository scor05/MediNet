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

    //Obtener usuario desde token
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
}