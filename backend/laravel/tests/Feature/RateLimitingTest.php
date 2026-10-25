<?php

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Route;

it('returns 429 after exceeding a public rate limit', function () {
    config()->set('rate_limits.registration', 2);

    Route::get('/_tests/rate-limit/public', fn () => response()->json(['ok' => true]))
        ->middleware('throttle:registration');

    $headers = ['REMOTE_ADDR' => '192.0.2.10'];

    $this->withServerVariables($headers)->getJson('/_tests/rate-limit/public')->assertOk();
    $this->withServerVariables($headers)->getJson('/_tests/rate-limit/public')->assertOk();
    $this->withServerVariables($headers)->getJson('/_tests/rate-limit/public')
        ->assertStatus(429)
        ->assertJson([
            'message' => 'Demasiadas solicitudes. Inténtalo de nuevo más tarde.',
        ]);
});

it('separates public limits using the client IP forwarded by Caddy', function () {
    config()->set('rate_limits.public_search', 1);

    Route::get('/_tests/rate-limit/proxy', fn () => response()->json(['ok' => true]))
        ->middleware('throttle:public-search');

    $proxy = ['REMOTE_ADDR' => '172.18.0.7'];

    $this->withServerVariables($proxy)
        ->withHeader('X-Forwarded-For', '192.0.2.21')
        ->getJson('/_tests/rate-limit/proxy')
        ->assertOk();

    $this->withServerVariables($proxy)
        ->withHeader('X-Forwarded-For', '192.0.2.22')
        ->getJson('/_tests/rate-limit/proxy')
        ->assertOk();

    $this->withServerVariables($proxy)
        ->withHeader('X-Forwarded-For', '192.0.2.21')
        ->getJson('/_tests/rate-limit/proxy')
        ->assertStatus(429);
});

it('limits authenticated creation operations independently by user', function () {
    config()->set('rate_limits.creation', 1);

    $firstUser = new User;
    $firstUser->id = 101;
    $secondUser = new User;
    $secondUser->id = 202;

    $firstRequest = Request::create('/api/appointments', 'POST');
    $firstRequest->setUserResolver(fn () => $firstUser);
    $secondRequest = Request::create('/api/appointments', 'POST');
    $secondRequest->setUserResolver(fn () => $secondUser);

    $limiter = RateLimiter::limiter('creation');
    $firstLimit = $limiter($firstRequest);
    $secondLimit = $limiter($secondRequest);
    $authenticatedLimiter = RateLimiter::limiter('authenticated');
    $authenticatedLimit = $authenticatedLimiter($firstRequest);

    expect($firstLimit->key)->toBe('user:101')
        ->and($secondLimit->key)->toBe('user:202')
        ->and($firstLimit->maxAttempts)->toBe(1)
        ->and($authenticatedLimit->key)->toBe('user:101');
});

it('attaches the expected limiters to sensitive API routes', function (string $method, string $uri, string $limiter) {
    $route = app('router')->getRoutes()->match(Request::create($uri, $method));

    expect($route->gatherMiddleware())->toContain('throttle:'.$limiter);
})->with([
    ['POST', '/api/auth/register', 'registration'],
    ['GET', '/api/public/doctors', 'public-search'],
    ['GET', '/api/public/clinics', 'public-search'],
    ['GET', '/api/public/slots', 'public-slots'],
    ['POST', '/api/public/appointments', 'creation'],
    ['POST', '/api/appointments', 'creation'],
    ['POST', '/api/schedules', 'creation'],
    ['POST', '/api/waitlists', 'creation'],
]);

it('rate limits Supabase token validation before protected endpoints', function () {
    $route = app('router')->getRoutes()->match(Request::create('/api/profile', 'GET'));
    $middleware = $route->gatherMiddleware();

    expect($middleware)->toContain('throttle:token-validation')
        ->and(array_search('throttle:token-validation', $middleware, true))
        ->toBeLessThan(array_search('supabase.auth', $middleware, true))
        ->and(array_search('supabase.auth', $middleware, true))
        ->toBeLessThan(array_search('throttle:authenticated', $middleware, true));
});
