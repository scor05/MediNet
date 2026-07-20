<?php

namespace Tests\Unit\Http\Middleware;

use App\Http\Middleware\SupabaseAuth;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tests\Unit\UnitTestCase;

class SupabaseAuthTest extends UnitTestCase
{
    public function test_invalid_supabase_token_is_rejected_before_the_request_continues(): void
    {
        $authService = $this->createMock(AuthService::class);
        $authService->expects($this->once())
            ->method('getUser')
            ->with('invalid-token')
            ->willReturn(null);

        $request = Request::create('/api/profile', 'GET');
        $request->headers->set('Authorization', 'Bearer invalid-token');

        $nextWasCalled = false;
        $response = (new SupabaseAuth($authService))->handle(
            $request,
            function () use (&$nextWasCalled): Response {
                $nextWasCalled = true;

                return new Response;
            },
        );

        $this->assertSame(401, $response->getStatusCode());
        $this->assertSame(
            ['message' => 'Token inválido o expirado'],
            $response->getData(true),
        );
        $this->assertFalse($nextWasCalled);
    }
}
