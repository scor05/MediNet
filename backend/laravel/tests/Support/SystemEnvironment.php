<?php

namespace Tests\Support;

use GuzzleHttp\Client;
use PDO;
use RuntimeException;

final class SystemEnvironment
{
    public static function backendUrl(string $path = ''): string
    {
        return self::url('SYSTEM_BACKEND_URL', 'http://backend:8000', $path);
    }

    public static function frontendUrl(string $path = ''): string
    {
        return self::url('SYSTEM_FRONTEND_URL', 'http://frontend', $path);
    }

    public static function reverbUrl(string $path = ''): string
    {
        return self::url('SYSTEM_REVERB_URL', 'http://reverb:8080', $path);
    }

    public static function expectedApiUrl(): string
    {
        return rtrim(self::environment('SYSTEM_EXPECTED_API_URL', 'https://medinet.lat/api'), '/');
    }

    public static function browserOrigin(): string
    {
        return rtrim(self::environment('SYSTEM_BROWSER_ORIGIN', 'http://localhost:3055'), '/');
    }

    public static function http(): Client
    {
        return new Client([
            'connect_timeout' => 3,
            'http_errors' => false,
            'timeout' => 10,
        ]);
    }

    public static function postgres(): PDO
    {
        $host = self::environment('SYSTEM_DB_HOST', self::environment('DB_HOST', 'db'));
        $port = self::environment('SYSTEM_DB_PORT', self::environment('DB_PORT', '5432'));
        $database = self::environment(
            'SYSTEM_DB_DATABASE',
            self::environment('DB_DATABASE', 'medinet'),
        );
        $username = self::environment(
            'SYSTEM_DB_USERNAME',
            self::environment('DB_USERNAME', 'postgres'),
        );
        $password = self::environment(
            'SYSTEM_DB_PASSWORD',
            self::environment('DB_PASSWORD', ''),
        );

        return new PDO(
            "pgsql:host={$host};port={$port};dbname={$database}",
            $username,
            $password,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ],
        );
    }

    public static function header(array $headers, string $name): ?string
    {
        foreach ($headers as $headerName => $values) {
            if (strcasecmp($headerName, $name) === 0) {
                return implode(', ', $values);
            }
        }

        return null;
    }

    private static function url(string $name, string $default, string $path): string
    {
        return rtrim(self::environment($name, $default), '/').'/'.ltrim($path, '/');
    }

    private static function environment(string $name, string $default): string
    {
        $value = getenv($name);

        if ($value === false || trim($value) === '') {
            return $default;
        }

        if (str_contains($value, "\0")) {
            throw new RuntimeException("Invalid null byte in {$name}.");
        }

        return $value;
    }
}
