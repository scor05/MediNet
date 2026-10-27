<?php

namespace Tests\Feature;

use App\Http\Middleware\IsClientAdmin;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\Request;
use Illuminate\Routing\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class ClientUserAuthorizationTest extends TestCase
{
    use DatabaseTransactions;

    private int $clientA;

    private int $clientB;

    protected function setUp(): void
    {
        parent::setUp();

        $suffix = Str::lower(Str::random(12));
        $now = now();
        $this->clientA = DB::table('clients')->insertGetId([
            'nit' => "AUTH-A-{$suffix}",
            'name' => 'Organización A',
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
        $this->clientB = DB::table('clients')->insertGetId([
            'nit' => "AUTH-B-{$suffix}",
            'name' => 'Organización B',
            'is_active' => true,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    public function test_all_client_user_routes_require_client_admin_middleware(): void
    {
        $routes = collect(app('router')->getRoutes()->getRoutes())
            ->filter(fn (Route $route): bool => preg_match(
                '#^api/clients/\{clientId\}/users(?:/\{userId\})?$#',
                $route->uri(),
            ) === 1);

        $this->assertCount(4, $routes);
        foreach ($routes as $route) {
            $this->assertContains('is.client.admin', $route->gatherMiddleware());
        }
    }

    public function test_admin_can_only_manage_the_organization_where_membership_is_active(): void
    {
        $actor = $this->createUser('admin@example.com');
        $this->addMembership($actor->id, $this->clientA, isAdmin: true, isActive: true);

        $this->assertSame(200, $this->authorize($actor, $this->clientA)->getStatusCode());
        $this->assertSame(403, $this->authorize($actor, $this->clientB)->getStatusCode());

        DB::table('client_users')
            ->where('id_client', $this->clientA)
            ->where('id_user', $actor->id)
            ->update(['is_active' => false]);

        $this->assertSame(403, $this->authorize($actor, $this->clientA)->getStatusCode());
    }

    public function test_superadmin_can_manage_members_without_a_client_membership(): void
    {
        $actor = $this->createUser('superadmin@example.com');
        DB::table('superadmins')->insert(['id_user' => $actor->id]);

        $this->assertSame(200, $this->authorize($actor, $this->clientB)->getStatusCode());
    }

    public function test_common_user_cannot_promote_or_reactivate_their_own_membership(): void
    {
        $actor = $this->createUser('member@example.com');
        $this->addMembership($actor->id, $this->clientA, isAdmin: false, isActive: true);
        $request = $this->clientRequest($actor, $this->clientA, [
            'role' => 2,
            'is_admin' => true,
            'is_active' => true,
        ]);
        $nextWasCalled = false;

        $response = app(IsClientAdmin::class)->handle(
            $request,
            function () use (&$nextWasCalled) {
                $nextWasCalled = true;

                return response()->json(['ok' => true]);
            },
        );

        $this->assertSame(403, $response->getStatusCode());
        $this->assertFalse($nextWasCalled);
        $this->assertDatabaseHas('client_users', [
            'id_client' => $this->clientA,
            'id_user' => $actor->id,
            'role' => 0,
            'is_admin' => false,
            'is_active' => true,
        ]);
    }

    private function authorize(User $actor, int $clientId)
    {
        return app(IsClientAdmin::class)->handle(
            $this->clientRequest($actor, $clientId),
            fn () => response()->json(['ok' => true]),
        );
    }

    private function clientRequest(
        User $actor,
        int $clientId,
        array $payload = [],
    ): Request {
        $request = Request::create(
            "/api/clients/{$clientId}/users/{$actor->id}",
            'PATCH',
            $payload,
        );
        $route = new Route(
            ['PATCH'],
            'api/clients/{clientId}/users/{userId}',
            fn () => null,
        );
        $route->bind($request);
        $request->setRouteResolver(fn () => $route);
        $request->setUserResolver(fn () => $actor);

        return $request;
    }

    private function createUser(string $email): User
    {
        $uniqueEmail = Str::before($email, '@')
            .'-'.Str::lower(Str::random(12))
            .'@'.Str::after($email, '@');

        return User::create([
            'name' => 'Usuario de prueba',
            'email' => $uniqueEmail,
            'is_active' => true,
        ]);
    }

    private function addMembership(
        int $userId,
        int $clientId,
        bool $isAdmin,
        bool $isActive,
    ): void {
        DB::table('client_users')->insert([
            'id_client' => $clientId,
            'id_user' => $userId,
            'role' => 0,
            'is_admin' => $isAdmin,
            'is_active' => $isActive,
        ]);
    }
}
