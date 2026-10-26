<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
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
        $supabaseUser = $this->createSupabaseUser($data['email'], $data['password']);

        $supabaseId = $supabaseUser['id'] ?? null;

        if (!is_string($supabaseId) || !Str::isUuid($supabaseId)) {
            throw new RegistrationException(
                'Error al crear usuario.',
                500
            );
        }

        // Crear usuario en tabla users local vinculado por el identificador de Supabase
        $this->userService->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'supabase_id' => $supabaseId,
            'phone' => $data['phone'] ?? null,
        ]);

        // Hacer sign in en Supabase Auth para obtener el token
        return $this->signIn($data['email'], $data['password']);
    }

    // Obtener usuario desde token
    public function getUser(string $token): ?array
    {
        $cacheKey = 'supabase_token_' . hash('sha256', $token);

        return Cache::store('file')->remember($cacheKey, 300, function () use ($token) {
            try {
                $response = Http::timeout(8)->withHeaders([
                    'Authorization' => 'Bearer ' . $token,
                    'apikey' => $this->anonKey,
                ])->get($this->url . '/auth/v1/user');
            } catch (\Throwable $e) {
                throw new RegistrationException(
                    'No se pudo comunicar con el servidor para validar el token.',
                    500
                );
            }

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
        });
    }

    // Vincular usuarios locales sin supabase_id con su cuenta de Supabase Auth usando el correo.
    // Sin $apply solo se reporta lo que se haría, sin modificar la base de datos.
    public function linkExistingAccounts(bool $apply): array
    {
        $supabaseIdsByEmail = [];
        $duplicatedEmails = [];

        foreach ($this->listSupabaseUsers() as $supabaseUser) {
            $email = Str::lower(trim((string) ($supabaseUser['email'] ?? '')));
            $supabaseId = $supabaseUser['id'] ?? null;

            if ($email === '' || !is_string($supabaseId) || !Str::isUuid($supabaseId)) {
                continue;
            }

            if (isset($supabaseIdsByEmail[$email])) {
                $duplicatedEmails[$email] = true;
            }

            $supabaseIdsByEmail[$email] = $supabaseId;
        }

        $report = ['linked' => [], 'not_found' => [], 'conflicts' => []];
        $claimedIds = [];

        foreach ($this->userService->getWithoutSupabaseId() as $user) {
            $email = Str::lower(trim($user->email));

            if (isset($duplicatedEmails[$email])) {
                $report['conflicts'][] = [$user->id, $user->email, 'Correo repetido en Supabase'];
                continue;
            }

            $supabaseId = $supabaseIdsByEmail[$email] ?? null;

            if (!$supabaseId) {
                $report['not_found'][] = [$user->id, $user->email];
                continue;
            }

            $ownerId = $claimedIds[$supabaseId] ?? $this->userService->getBySupabaseId($supabaseId)?->id;

            if ($ownerId) {
                $report['conflicts'][] = [$user->id, $user->email, "Identificador ya vinculado al usuario {$ownerId}"];
                continue;
            }

            if ($apply) {
                $user->forceFill(['supabase_id' => $supabaseId])->save();
            }

            $claimedIds[$supabaseId] = $user->id;

            $report['linked'][] = [$user->id, $user->email, $supabaseId];
        }

        return $report;
    }

    // Listar todos los usuarios de Supabase Auth recorriendo las páginas de la API de administración
    private function listSupabaseUsers(): array
    {
        $users = [];
        $perPage = 200;

        for ($page = 1; ; $page++) {
            try {
                $response = Http::timeout(15)->withHeaders([
                    'Authorization' => 'Bearer ' . $this->serviceRoleKey,
                    'apikey' => $this->serviceRoleKey,
                ])->get($this->url . '/auth/v1/admin/users', [
                    'page' => $page,
                    'per_page' => $perPage,
                ]);
            } catch (\Throwable $e) {
                throw new RegistrationException(
                    'No se pudo comunicar con el servidor para listar los usuarios.',
                    500
                );
            }

            if (!$response->successful()) {
                throw new RegistrationException(
                    'Error al listar los usuarios de Supabase.',
                    500
                );
            }

            $pageUsers = $response->json('users') ?? [];
            $users = array_merge($users, $pageUsers);

            if (count($pageUsers) < $perPage) {
                return $users;
            }
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
                        'email_confirm' => true,
                    ]);
        } catch (\Throwable $e) {
            throw new RegistrationException(
                'No se pudo comunicar con el servidor para crear el usuario.',
                500
            );
        }

        if ($response->successful()) {
            return $response->json();
        }

        throw new RegistrationException(
            'Error al crear usuario.',
            500
        );
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
        } catch (\Throwable $e) {
            throw new RegistrationException(
                'No se pudo comunicar con el servidor para iniciar sesión.',
                500
            );
        }

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
    }
}