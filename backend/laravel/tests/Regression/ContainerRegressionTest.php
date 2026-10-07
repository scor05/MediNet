<?php

use Tests\Support\SystemEnvironment;

it('preserves the public API ping response contract', function () {
    $response = SystemEnvironment::http()->get(
        SystemEnvironment::backendUrl('/api/ping'),
        ['headers' => ['Accept' => 'application/json']],
    );

    expect($response->getStatusCode())->toBe(200)
        ->and(json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR))
        ->toBe(['message' => 'pong']);
});

it('preserves nginx SPA fallback for direct application routes', function () {
    $http = SystemEnvironment::http();
    $root = $http->get(SystemEnvironment::frontendUrl('/'));
    $register = $http->get(SystemEnvironment::frontendUrl('/register'));

    expect($root->getStatusCode())->toBe(200)
        ->and($register->getStatusCode())->toBe(200)
        ->and(strtolower($register->getHeaderLine('Content-Type')))->toContain('text/html')
        ->and((string) $register->getBody())->toBe((string) $root->getBody());
});

it('preserves CORS preflight support for authenticated API requests', function () {
    $requestedHeaders = 'authorization,content-type,cache-control,pragma';
    $response = SystemEnvironment::http()->request(
        'OPTIONS',
        SystemEnvironment::backendUrl('/api/profile'),
        [
            'headers' => [
                'Access-Control-Request-Headers' => $requestedHeaders,
                'Access-Control-Request-Method' => 'GET',
                'Origin' => SystemEnvironment::browserOrigin(),
            ],
        ],
    );

    $allowOrigin = SystemEnvironment::header(
        $response->getHeaders(),
        'Access-Control-Allow-Origin',
    );
    $allowMethods = strtolower((string) SystemEnvironment::header(
        $response->getHeaders(),
        'Access-Control-Allow-Methods',
    ));
    $allowHeaders = strtolower((string) SystemEnvironment::header(
        $response->getHeaders(),
        'Access-Control-Allow-Headers',
    ));
    $validAllowedOrigins = ['*', SystemEnvironment::browserOrigin()];

    expect($response->getStatusCode())->toBe(204)
        ->and($validAllowedOrigins)->toContain($allowOrigin)
        ->and($allowMethods)->toContain('get');

    foreach (explode(',', $requestedHeaders) as $header) {
        expect($allowHeaders)->toContain($header);
    }
});
