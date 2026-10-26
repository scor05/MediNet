<?php

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

beforeEach(function () {
    config([
        'supabase.url' => 'https://supabase.test',
        'supabase.anon_key' => 'anon-key',
        'supabase.service_role_key' => 'service-role-key',
    ]);
});

function supabaseLinkCreateUser(string $email, ?string $supabaseId = null): int
{
    return DB::table('users')->insertGetId([
        'name' => 'Usuario Supabase',
        'email' => $email,
        'supabase_id' => $supabaseId,
        'phone' => '5555-0000',
        'is_active' => true,
        'created_at' => now(),
        'updated_at' => now(),
    ]);
}

it('stores the supabase identifier when a user registers', function () {
    $suffix = Str::lower(Str::random(12));
    $email = "registro-{$suffix}@example.test";
    $supabaseId = (string) Str::uuid();

    Http::fake([
        'supabase.test/auth/v1/admin/users' => Http::response(['id' => $supabaseId, 'email' => $email]),
        'supabase.test/auth/v1/token*' => Http::response(['access_token' => 'token', 'user' => ['id' => $supabaseId]]),
    ]);

    $this->postJson('/api/auth/register', [
        'name' => 'Paciente Nuevo',
        'email' => $email,
        'password' => 'secreto-seguro',
        'phone' => '5555-1234',
    ])->assertCreated();

    expect(User::where('email', $email)->value('supabase_id'))->toBe($supabaseId);
});

it('links existing users by email only when --apply is given', function () {
    $suffix = Str::lower(Str::random(12));
    $email = "existente-{$suffix}@example.test";
    $supabaseId = (string) Str::uuid();
    $userId = supabaseLinkCreateUser($email);

    Http::fake([
        'supabase.test/auth/v1/admin/users*' => Http::response([
            'users' => [['id' => $supabaseId, 'email' => Str::upper($email)]],
        ]),
    ]);

    $this->artisan('users:link-supabase')->assertSuccessful();
    expect(User::find($userId)->supabase_id)->toBeNull();

    $this->artisan('users:link-supabase', ['--apply' => true])->assertSuccessful();
    expect(User::find($userId)->supabase_id)->toBe($supabaseId);
});

it('does not reuse a supabase identifier already linked to another user', function () {
    $suffix = Str::lower(Str::random(12));
    $supabaseId = (string) Str::uuid();
    $ownerId = supabaseLinkCreateUser("duenio-{$suffix}@example.test", $supabaseId);
    $otherEmail = "otro-{$suffix}@example.test";
    $otherId = supabaseLinkCreateUser($otherEmail);

    Http::fake([
        'supabase.test/auth/v1/admin/users*' => Http::response([
            'users' => [['id' => $supabaseId, 'email' => $otherEmail]],
        ]),
    ]);

    $this->artisan('users:link-supabase', ['--apply' => true])->assertSuccessful();

    expect(User::find($otherId)->supabase_id)->toBeNull()
        ->and(User::find($ownerId)->supabase_id)->toBe($supabaseId);
});
