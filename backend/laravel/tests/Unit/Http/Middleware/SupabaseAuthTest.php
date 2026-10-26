<?php

namespace Tests\Unit\Http\Middleware;

use App\Http\Middleware\SupabaseAuth;
use App\Models\User;
use App\Services\AuthService;
use App\Services\UserService;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tests\Unit\UnitTestCase;

class SupabaseAuthTest extends UnitTestCase
{
    private const SUPABASE_ID = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';

    public function test_invalid_supabase_token_is_rejected_before_the_request_continues(): void
    {
        $authService = $this->createMock(AuthService::class);
        $authService->expects($this->once())
            ->method('getUser')
            ->with('invalid-token')
            ->willReturn(null);

        $userService = $this->createMock(UserService::class);
        $userService->expects($this->never())->method('getBySupabaseId');

        [$response, $nextWasCalled] = $this->runMiddleware($authService, $userService, 'invalid-token');

        $this->assertSame(401, $response->getStatusCode());
        $this->assertSame(
            ['message' => 'Token inválido o expirado'],
            $response->getData(true),
        );
        $this->assertFalse($nextWasCalled);
    }

    public function test_valid_token_resolves_the_local_user_by_supabase_id(): void
    {
        $localUser = $this->localUser(email: 'paciente@example.test', active: true);

        $userService = $this->createMock(UserService::class);
        $userService->expects($this->once())
            ->method('getBySupabaseId')
            ->with(self::SUPABASE_ID)
            ->willReturn($localUser);

        [$response, $nextWasCalled, $request] = $this->runMiddleware(
            $this->authServiceReturning(['id' => self::SUPABASE_ID, 'email' => 'paciente@example.test']),
            $userService,
        );

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($nextWasCalled);
        $this->assertSame($localUser, $request->user());
    }

    public function test_user_whose_email_changed_in_supabase_is_still_resolved_by_its_identifier(): void
    {
        $localUser = $this->localUser(email: 'correo-anterior@example.test', active: true);

        $userService = $this->createMock(UserService::class);
        $userService->expects($this->once())
            ->method('getBySupabaseId')
            ->with(self::SUPABASE_ID)
            ->willReturn($localUser);

        [$response, $nextWasCalled, $request] = $this->runMiddleware(
            $this->authServiceReturning(['id' => self::SUPABASE_ID, 'email' => 'correo-nuevo@example.test']),
            $userService,
        );

        $this->assertSame(200, $response->getStatusCode());
        $this->assertTrue($nextWasCalled);
        $this->assertSame($localUser, $request->user());
    }

    public function test_local_user_with_the_same_email_but_another_identifier_is_not_accepted(): void
    {
        $userService = $this->createMock(UserService::class);
        $userService->expects($this->once())
            ->method('getBySupabaseId')
            ->with(self::SUPABASE_ID)
            ->willReturn(null);

        [$response, $nextWasCalled] = $this->runMiddleware(
            $this->authServiceReturning(['id' => self::SUPABASE_ID, 'email' => 'existente@example.test']),
            $userService,
        );

        $this->assertSame(403, $response->getStatusCode());
        $this->assertSame(
            ['message' => 'Usuario no registrado en el sistema'],
            $response->getData(true),
        );
        $this->assertFalse($nextWasCalled);
    }

    public function test_unknown_supabase_identifier_is_rejected_with_403(): void
    {
        $userService = $this->createStub(UserService::class);
        $userService->method('getBySupabaseId')->willReturn(null);

        [$response, $nextWasCalled] = $this->runMiddleware(
            $this->authServiceReturning(['id' => self::SUPABASE_ID, 'email' => 'desconocido@example.test']),
            $userService,
        );

        $this->assertSame(403, $response->getStatusCode());
        $this->assertFalse($nextWasCalled);
    }

    public function test_inactive_local_user_is_rejected_with_403(): void
    {
        $userService = $this->createStub(UserService::class);
        $userService->method('getBySupabaseId')
            ->willReturn($this->localUser(email: 'inactivo@example.test', active: false));

        [$response, $nextWasCalled, $request] = $this->runMiddleware(
            $this->authServiceReturning(['id' => self::SUPABASE_ID, 'email' => 'inactivo@example.test']),
            $userService,
        );

        $this->assertSame(403, $response->getStatusCode());
        $this->assertSame(
            ['message' => 'Usuario inactivo'],
            $response->getData(true),
        );
        $this->assertFalse($nextWasCalled);
        $this->assertNull($request->user());
    }

    public function test_supabase_response_without_a_valid_identifier_is_rejected(): void
    {
        $userService = $this->createMock(UserService::class);
        $userService->expects($this->never())->method('getBySupabaseId');

        [$response, $nextWasCalled] = $this->runMiddleware(
            $this->authServiceReturning(['id' => 'no-es-un-uuid', 'email' => 'paciente@example.test']),
            $userService,
        );

        $this->assertSame(401, $response->getStatusCode());
        $this->assertFalse($nextWasCalled);
    }

    private function authServiceReturning(array $supabaseUser): AuthService
    {
        $authService = $this->createMock(AuthService::class);
        $authService->method('getUser')->with('valid-token')->willReturn($supabaseUser);

        return $authService;
    }

    private function localUser(string $email, bool $active): User
    {
        return (new User)->forceFill([
            'id' => 10,
            'name' => 'Usuario de Prueba',
            'email' => $email,
            'supabase_id' => self::SUPABASE_ID,
            'is_active' => $active,
        ]);
    }

    private function runMiddleware(AuthService $authService, UserService $userService, string $token = 'valid-token'): array
    {
        $request = Request::create('/api/profile', 'GET');
        $request->headers->set('Authorization', "Bearer {$token}");

        $nextWasCalled = false;
        $response = (new SupabaseAuth($authService, $userService))->handle(
            $request,
            function () use (&$nextWasCalled): Response {
                $nextWasCalled = true;

                return new Response;
            },
        );

        return [$response, $nextWasCalled, $request];
    }
}
