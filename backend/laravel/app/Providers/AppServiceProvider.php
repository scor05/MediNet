<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('registration', function (Request $request) {
            return $this->perMinuteLimit(
                config('rate_limits.registration'),
                'ip:'.$request->ip()
            );
        });

        RateLimiter::for('token-validation', function (Request $request) {
            return $this->perMinuteLimit(
                config('rate_limits.token_validation'),
                'ip:'.$request->ip()
            );
        });

        RateLimiter::for('authenticated', function (Request $request) {
            $key = $request->user()?->getKey();

            return $this->perMinuteLimit(
                config('rate_limits.authenticated'),
                $key !== null ? 'user:'.$key : 'ip:'.$request->ip()
            );
        });

        RateLimiter::for('public-search', function (Request $request) {
            return $this->perMinuteLimit(
                config('rate_limits.public_search'),
                'ip:'.$request->ip()
            );
        });

        RateLimiter::for('public-slots', function (Request $request) {
            return $this->perMinuteLimit(
                config('rate_limits.public_slots'),
                'ip:'.$request->ip()
            );
        });

        RateLimiter::for('creation', function (Request $request) {
            $key = $request->user()?->getKey();

            return $this->perMinuteLimit(
                config('rate_limits.creation'),
                $key !== null ? 'user:'.$key : 'ip:'.$request->ip()
            );
        });
    }

    private function perMinuteLimit(int $maximumAttempts, string $key): Limit
    {
        return Limit::perMinute($maximumAttempts)
            ->by($key)
            ->response(fn (Request $request, array $headers) => response()->json([
                'message' => 'Demasiadas solicitudes. Inténtalo de nuevo más tarde.',
            ], 429, $headers));
    }
}
