<?php

use App\Http\Middleware\SupabaseAuth;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

function userSecurityAuthenticate(User $user): void
{
    app()->instance(SupabaseAuth::class, new class($user)
    {
        public function __construct(private User $user) {}

        public function handle(Request $request, Closure $next)
        {
            $request->setUserResolver(fn () => $this->user);

            return $next($request);
        }
    });
}

function userSecurityFixture(): array
{
    $suffix = Str::lower(Str::random(12));
    $now = now();

    $createUser = function (string $name, bool $active = true) use ($suffix, $now): int {
        return DB::table('users')->insertGetId([
            'name' => $name,
            'email' => Str::slug($name)."-{$suffix}@example.test",
            'phone' => '5555-0000',
            'fcm_token' => "private-token-{$suffix}",
            'is_active' => $active,
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    };

    $ordinary = $createUser('Usuario Común');
    $adminA = $createUser('Administrador A');
    $memberA = $createUser('Miembro A');
    $adminB = $createUser('Administrador B');
    $memberB = $createUser('Miembro B');
    $superadmin = $createUser('Superadministrador');
    $unassigned = $createUser('Usuario Sin Organización');
    $inactiveAdmin = $createUser('Administrador Inactivo', false);

    $clientA = DB::table('clients')->insertGetId([
        'nit' => "USER-A-{$suffix}",
        'name' => 'Organización A',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);
    $clientB = DB::table('clients')->insertGetId([
        'nit' => "USER-B-{$suffix}",
        'name' => 'Organización B',
        'is_active' => true,
        'created_at' => $now,
        'updated_at' => $now,
    ]);

    DB::table('client_users')->insert([
        [
            'id_client' => $clientA,
            'id_user' => $adminA,
            'role' => 0,
            'is_admin' => true,
            'is_active' => true,
        ],
        [
            'id_client' => $clientA,
            'id_user' => $memberA,
            'role' => 1,
            'is_admin' => false,
            'is_active' => true,
        ],
        [
            'id_client' => $clientB,
            'id_user' => $adminB,
            'role' => 0,
            'is_admin' => true,
            'is_active' => true,
        ],
        [
            'id_client' => $clientB,
            'id_user' => $memberB,
            'role' => 2,
            'is_admin' => false,
            'is_active' => true,
        ],
        [
            'id_client' => $clientA,
            'id_user' => $inactiveAdmin,
            'role' => 0,
            'is_admin' => true,
            'is_active' => true,
        ],
    ]);

    DB::table('superadmins')->insert(['id_user' => $superadmin]);

    return compact(
        'ordinary',
        'adminA',
        'memberA',
        'adminB',
        'memberB',
        'superadmin',
        'unassigned',
        'inactiveAdmin',
        'suffix',
    );
}

it('allows an ordinary user to view and edit only safe fields of their own account', function () {
    $fixture = userSecurityFixture();
    userSecurityAuthenticate(User::findOrFail($fixture['ordinary']));
    $uri = '/api/users/'.$fixture['ordinary'];

    $this->withToken('valid-test-token')
        ->getJson($uri)
        ->assertOk()
        ->assertJsonPath('id', $fixture['ordinary'])
        ->assertJsonMissingPath('fcm_token')
        ->assertJsonMissingPath('created_at')
        ->assertJsonMissingPath('updated_at');

    $this->withToken('valid-test-token')
        ->patchJson($uri, [
            'name' => 'Nombre Propio Actualizado',
            'phone' => '5555-1111',
        ])
        ->assertOk()
        ->assertJsonPath('name', 'Nombre Propio Actualizado')
        ->assertJsonPath('phone', '5555-1111');
});

it('denies global and horizontal user access to an ordinary user', function () {
    $fixture = userSecurityFixture();
    userSecurityAuthenticate(User::findOrFail($fixture['ordinary']));
    $foreignUri = '/api/users/'.$fixture['memberA'];

    $this->withToken('valid-test-token')->getJson('/api/users')->assertForbidden();
    $this->withToken('valid-test-token')->getJson($foreignUri)->assertForbidden();
    $this->withToken('valid-test-token')
        ->patchJson($foreignUri, ['name' => 'Intento Horizontal'])
        ->assertForbidden();
    $this->withToken('valid-test-token')->deleteJson($foreignUri)->assertForbidden();
});

it('limits an organization administrators list and reads to their organizations', function () {
    $fixture = userSecurityFixture();
    userSecurityAuthenticate(User::findOrFail($fixture['adminA']));

    $response = $this->withToken('valid-test-token')->getJson('/api/users');

    $response->assertOk();
    expect(collect($response->json())->pluck('id')->sort()->values()->all())
        ->toBe(collect([
            $fixture['adminA'],
            $fixture['memberA'],
            $fixture['inactiveAdmin'],
        ])->sort()->values()->all());
    expect(collect($response->json())->every(
        fn (array $user) => array_keys($user) === ['id', 'name', 'email', 'is_active']
    ))->toBeTrue();

    $this->withToken('valid-test-token')
        ->getJson('/api/users/'.$fixture['memberA'])
        ->assertOk();
    $this->withToken('valid-test-token')
        ->getJson('/api/users/'.$fixture['memberB'])
        ->assertForbidden();
});

it('lets an organization administrator edit safe fields but not global account state', function () {
    $fixture = userSecurityFixture();
    userSecurityAuthenticate(User::findOrFail($fixture['adminA']));
    $memberUri = '/api/users/'.$fixture['memberA'];

    $this->withToken('valid-test-token')
        ->patchJson($memberUri, [
            'name' => 'Miembro A Actualizado',
            'phone' => '5555-2222',
        ])
        ->assertOk()
        ->assertJsonPath('name', 'Miembro A Actualizado');

    $this->withToken('valid-test-token')
        ->patchJson($memberUri, ['is_active' => false])
        ->assertForbidden();
    $this->withToken('valid-test-token')
        ->patchJson($memberUri, [
            'email' => "forged-{$fixture['suffix']}@example.test",
        ])
        ->assertForbidden();
    $this->withToken('valid-test-token')->deleteJson($memberUri)->assertForbidden();

    $this->withToken('valid-test-token')
        ->patchJson('/api/users/'.$fixture['memberB'], ['name' => 'Fuera de Organización'])
        ->assertForbidden();

    expect(User::findOrFail($fixture['memberA'])->is_active)->toBeTrue();
});

it('allows a superadministrator to perform global operations without exposing tokens', function () {
    $fixture = userSecurityFixture();
    userSecurityAuthenticate(User::findOrFail($fixture['superadmin']));

    $response = $this->withToken('valid-test-token')->getJson('/api/users');
    $response->assertOk();
    expect(collect($response->json())->pluck('id'))
        ->toContain($fixture['memberA'], $fixture['memberB'], $fixture['unassigned']);
    expect(json_encode($response->json()))->not->toContain('private-token-');

    $updatedEmail = "global-{$fixture['suffix']}@example.test";
    $this->withToken('valid-test-token')
        ->patchJson('/api/users/'.$fixture['memberB'], [
            'email' => $updatedEmail,
            'is_active' => false,
        ])
        ->assertOk()
        ->assertJsonPath('email', $updatedEmail)
        ->assertJsonPath('is_active', false)
        ->assertJsonMissingPath('fcm_token');

    $this->withToken('valid-test-token')
        ->deleteJson('/api/users/'.$fixture['unassigned'])
        ->assertNoContent();
    expect(User::find($fixture['unassigned']))->toBeNull();
});

it('denies user administration to an inactive actor even with an admin membership', function () {
    $fixture = userSecurityFixture();
    userSecurityAuthenticate(User::findOrFail($fixture['inactiveAdmin']));

    $this->withToken('valid-test-token')->getJson('/api/users')->assertForbidden();
    $this->withToken('valid-test-token')
        ->getJson('/api/users/'.$fixture['memberA'])
        ->assertForbidden();
});
