<?php

use Psr\Http\Message\ResponseInterface;
use Tests\Support\SystemEnvironment;

const SYSTEM_ACTIVE_SUPABASE_ID = '11111111-1111-4111-8111-111111111111';
const SYSTEM_INACTIVE_SUPABASE_ID = '33333333-3333-4333-8333-333333333333';

function systemJsonResponse(ResponseInterface $response): array
{
    return json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR);
}

function systemInsertUser(
    PDO $database,
    string $name,
    string $email,
    ?string $supabaseId,
    bool $active = true,
): int {
    $statement = $database->prepare(<<<'SQL'
        INSERT INTO users (name, email, supabase_id, is_active, created_at, updated_at)
        VALUES (:name, :email, :supabase_id, :is_active, NOW(), NOW())
        RETURNING id
        SQL);
    $statement->bindValue(':name', $name);
    $statement->bindValue(':email', $email);
    $statement->bindValue(':supabase_id', $supabaseId);
    $statement->bindValue(':is_active', $active, PDO::PARAM_BOOL);
    $statement->execute();

    return (int) $statement->fetchColumn();
}

function systemDeleteUser(PDO $database, int $userId): void
{
    $statement = $database->prepare('DELETE FROM users WHERE id = :id');
    $statement->execute(['id' => $userId]);
}

it('integrates the public doctors API with PostgreSQL', function () {
    $response = SystemEnvironment::http()->get(
        SystemEnvironment::backendUrl('/api/public/doctors'),
        ['headers' => ['Accept' => 'application/json']],
    );

    expect($response->getStatusCode())->toBe(200);

    $apiDoctors = json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR);
    expect($apiDoctors)->toBeArray();

    $statement = SystemEnvironment::postgres()->query(<<<'SQL'
        SELECT DISTINCT users.id
        FROM users
        INNER JOIN client_users ON client_users.id_user = users.id
        INNER JOIN schedules ON schedules.id_doctor = users.id
        INNER JOIN clinics ON clinics.id = schedules.id_clinic
        WHERE users.is_active = TRUE
          AND client_users.role = 1
          AND client_users.is_active = TRUE
          AND schedules.is_active = TRUE
          AND clinics.is_active = TRUE
        ORDER BY users.id
        SQL);

    $databaseIds = array_map('intval', $statement->fetchAll(PDO::FETCH_COLUMN));
    $apiIds = array_map(
        'intval',
        array_column($apiDoctors, 'id'),
    );
    sort($apiIds);

    expect($apiIds)->toBe($databaseIds);
});

it('integrates the frontend artifact with the reachable backend API', function () {
    $http = SystemEnvironment::http();
    $index = $http->get(SystemEnvironment::frontendUrl('/'));
    $bundle = $http->get(SystemEnvironment::frontendUrl('/main.dart.js'));
    $ping = $http->get(SystemEnvironment::backendUrl('/api/ping'));

    expect($index->getStatusCode())->toBe(200)
        ->and(strtolower($index->getHeaderLine('Content-Type')))->toContain('text/html')
        ->and((string) $index->getBody())->toContain('flutter_bootstrap.js')
        ->and($bundle->getStatusCode())->toBe(200)
        ->and((string) $bundle->getBody())->toContain(SystemEnvironment::expectedApiUrl())
        ->and($ping->getStatusCode())->toBe(200);
});

it('connects the backend network to the Reverb websocket service', function () {
    $response = SystemEnvironment::http()->get(SystemEnvironment::reverbUrl('/up'));

    expect($response->getStatusCode())->toBe(200);
});

it('rejects unauthenticated requests at protected API boundaries', function (
    string $method,
    string $path,
) {
    $response = SystemEnvironment::http()->request(
        $method,
        SystemEnvironment::backendUrl($path),
        ['json' => []],
    );

    expect($response->getStatusCode())->toBe(401)
        ->and(systemJsonResponse($response)['message'] ?? null)
        ->toBe('Token no proporcionado');
})->with([
    'general appointments' => ['GET', '/api/appointments'],
    'public appointment creation' => ['POST', '/api/public/appointments'],
    'general users' => ['GET', '/api/users'],
    'waitlists' => ['GET', '/api/waitlists'],
    'notifications' => ['GET', '/api/notifications'],
    'notification preferences' => ['GET', '/api/notification-preferences'],
]);

it('resolves an authenticated Supabase identity to its active local user', function () {
    $database = SystemEnvironment::postgres();
    $userId = systemInsertUser(
        $database,
        'Active system patient',
        'active.system@example.test',
        SYSTEM_ACTIVE_SUPABASE_ID,
    );

    try {
        $response = SystemEnvironment::http()->get(
            SystemEnvironment::backendUrl('/api/profile'),
            ['headers' => ['Authorization' => 'Bearer system-active-token']],
        );

        expect($response->getStatusCode())->toBe(200)
            ->and((int) (systemJsonResponse($response)['id'] ?? 0))->toBe($userId);
    } finally {
        systemDeleteUser($database, $userId);
    }
});

it('rejects an inactive local user even when Supabase accepts the token', function () {
    $database = SystemEnvironment::postgres();
    $userId = systemInsertUser(
        $database,
        'Inactive system patient',
        'inactive.system@example.test',
        SYSTEM_INACTIVE_SUPABASE_ID,
        false,
    );

    try {
        $response = SystemEnvironment::http()->get(
            SystemEnvironment::backendUrl('/api/profile'),
            ['headers' => ['Authorization' => 'Bearer system-inactive-token']],
        );

        expect($response->getStatusCode())->toBe(403)
            ->and(systemJsonResponse($response)['message'] ?? null)->toBe('Usuario inactivo');
    } finally {
        systemDeleteUser($database, $userId);
    }
});

it('does not authenticate by email when the Supabase identifier differs', function () {
    $database = SystemEnvironment::postgres();
    $userId = systemInsertUser(
        $database,
        'Same email system patient',
        'same-email.system@example.test',
        '55555555-5555-4555-8555-555555555555',
    );

    try {
        $response = SystemEnvironment::http()->get(
            SystemEnvironment::backendUrl('/api/profile'),
            ['headers' => ['Authorization' => 'Bearer system-unknown-token']],
        );

        expect($response->getStatusCode())->toBe(403)
            ->and(systemJsonResponse($response)['message'] ?? null)
            ->toBe('Usuario no registrado en el sistema');
    } finally {
        systemDeleteUser($database, $userId);
    }
});

it('prevents a patient from reading another user by an arbitrary ID', function () {
    $database = SystemEnvironment::postgres();
    $actorId = systemInsertUser(
        $database,
        'Authorized system patient',
        'active.system@example.test',
        SYSTEM_ACTIVE_SUPABASE_ID,
    );
    $otherId = systemInsertUser(
        $database,
        'Unrelated system patient',
        'unrelated.system@example.test',
        null,
    );
    $headers = ['Authorization' => 'Bearer system-active-token'];

    try {
        $ownResponse = SystemEnvironment::http()->get(
            SystemEnvironment::backendUrl("/api/users/{$actorId}"),
            ['headers' => $headers],
        );
        $foreignResponse = SystemEnvironment::http()->get(
            SystemEnvironment::backendUrl("/api/users/{$otherId}"),
            ['headers' => $headers],
        );
        $ownUser = systemJsonResponse($ownResponse);

        expect($ownResponse->getStatusCode())->toBe(200)
            ->and((int) ($ownUser['id'] ?? 0))->toBe($actorId)
            ->and($ownUser)->not->toHaveKey('supabase_id')
            ->and($foreignResponse->getStatusCode())->toBe(403);
    } finally {
        systemDeleteUser($database, $otherId);
        systemDeleteUser($database, $actorId);
    }
});

it('derives the public appointment patient and isolates appointment access', function () {
    $database = SystemEnvironment::postgres();
    $patientId = systemInsertUser(
        $database,
        'Authenticated system patient',
        'active.system@example.test',
        SYSTEM_ACTIVE_SUPABASE_ID,
    );
    $doctorId = systemInsertUser(
        $database,
        'System doctor',
        'doctor.system@example.test',
        null,
    );
    $suffix = bin2hex(random_bytes(5));
    $clientId = (int) $database->query(<<<SQL
        INSERT INTO clients (nit, name, is_active, created_at, updated_at)
        VALUES ('system-{$suffix}', 'System client', TRUE, NOW(), NOW())
        RETURNING id
        SQL)->fetchColumn();
    $clinicId = (int) $database->query(<<<SQL
        INSERT INTO clinics (name, address, phone, email, id_client, is_active, created_at, updated_at)
        VALUES (
            'System clinic',
            'Integration address',
            'system-{$suffix}',
            'clinic-{$suffix}@example.test',
            {$clientId},
            TRUE,
            NOW(),
            NOW()
        )
        RETURNING id
        SQL)->fetchColumn();
    $database->exec(<<<SQL
        INSERT INTO client_users (id_client, id_user, role, is_admin, is_active)
        VALUES ({$clientId}, {$doctorId}, 1, FALSE, TRUE)
        SQL);
    $date = new DateTimeImmutable('+14 days');
    $dayOfWeek = (int) $date->format('N') - 1;
    $scheduleId = (int) $database->query(<<<SQL
        INSERT INTO schedules (
            id_doctor,
            id_clinic,
            day_of_week,
            start_time,
            end_time,
            is_active,
            duration,
            created_at,
            updated_at
        ) VALUES (
            {$doctorId},
            {$clinicId},
            {$dayOfWeek},
            '09:00',
            '10:00',
            TRUE,
            30,
            NOW(),
            NOW()
        )
        RETURNING id
        SQL)->fetchColumn();
    $appointmentId = null;
    $foreignAppointmentId = null;

    try {
        $response = SystemEnvironment::http()->post(
            SystemEnvironment::backendUrl('/api/public/appointments'),
            [
                'headers' => ['Authorization' => 'Bearer system-active-token'],
                'json' => [
                    'id_schedule' => $scheduleId,
                    'id_patient' => $doctorId,
                    'name_patient' => 'Forged patient',
                    'date' => $date->format('Y-m-d'),
                    'start_time' => '09:00',
                ],
            ],
        );
        $appointment = systemJsonResponse($response);
        $appointmentId = (int) ($appointment['id'] ?? 0);
        $persisted = $database->query(<<<SQL
            SELECT id_patient, name_patient, created_by, status
            FROM appointments
            WHERE id = {$appointmentId}
            SQL)->fetch();
        $appointmentDate = $date->format('Y-m-d');
        $foreignAppointmentId = (int) $database->query(<<<SQL
            INSERT INTO appointments (
                id_schedule,
                id_patient,
                name_patient,
                date,
                status,
                start_time,
                created_by,
                updated_by,
                created_at,
                updated_at
            ) VALUES (
                {$scheduleId},
                {$doctorId},
                'Foreign system patient',
                '{$appointmentDate}',
                'requested',
                '09:30',
                {$doctorId},
                {$doctorId},
                NOW(),
                NOW()
            )
            RETURNING id
            SQL)->fetchColumn();
        $http = SystemEnvironment::http();
        $authorization = ['Authorization' => 'Bearer system-active-token'];
        $visibleAppointments = systemJsonResponse($http->get(
            SystemEnvironment::backendUrl('/api/appointments'),
            ['headers' => $authorization],
        ));
        $visibleIds = array_map(
            static fn (array $item): int => (int) $item['id'],
            $visibleAppointments,
        );
        $foreignShow = $http->get(
            SystemEnvironment::backendUrl("/api/appointments/{$foreignAppointmentId}"),
            ['headers' => $authorization],
        );
        $foreignUpdate = $http->patch(
            SystemEnvironment::backendUrl("/api/appointments/{$foreignAppointmentId}"),
            [
                'headers' => $authorization,
                'json' => ['status' => 'cancelled'],
            ],
        );
        $foreignDelete = $http->delete(
            SystemEnvironment::backendUrl("/api/appointments/{$foreignAppointmentId}"),
            ['headers' => $authorization],
        );

        expect($response->getStatusCode())->toBe(201)
            ->and((int) $persisted['id_patient'])->toBe($patientId)
            ->and((int) $persisted['created_by'])->toBe($patientId)
            ->and($persisted['name_patient'])->toBe('Authenticated system patient')
            ->and($persisted['status'])->toBe('requested')
            ->and($visibleIds)->toContain($appointmentId)
            ->and($visibleIds)->not->toContain($foreignAppointmentId)
            ->and($foreignShow->getStatusCode())->toBe(403)
            ->and($foreignUpdate->getStatusCode())->toBe(403)
            ->and($foreignDelete->getStatusCode())->toBe(403)
            ->and((int) $database->query(
                "SELECT COUNT(*) FROM appointments WHERE id = {$foreignAppointmentId}"
            )->fetchColumn())->toBe(1);
    } finally {
        if ($foreignAppointmentId !== null && $foreignAppointmentId > 0) {
            $database->exec("DELETE FROM appointments WHERE id = {$foreignAppointmentId}");
        }
        if ($appointmentId !== null && $appointmentId > 0) {
            $database->exec("DELETE FROM appointments WHERE id = {$appointmentId}");
        }
        $database->exec("DELETE FROM schedules WHERE id = {$scheduleId}");
        $database->exec(
            "DELETE FROM client_users WHERE id_client = {$clientId} AND id_user = {$doctorId}"
        );
        $database->exec("DELETE FROM clinics WHERE id = {$clinicId}");
        $database->exec("DELETE FROM clients WHERE id = {$clientId}");
        systemDeleteUser($database, $doctorId);
        systemDeleteUser($database, $patientId);
    }
});

it('applies the public search rate limit across real HTTP requests', function () {
    $http = SystemEnvironment::http();
    $successfulRequests = 0;
    $limited = null;

    // Other integration cases may already have consumed one request from the
    // same proxy IP. What matters here is that the shared counter eventually
    // rejects traffic instead of being reset on every HTTP request.
    for ($attempt = 1; $attempt <= 61; $attempt++) {
        $response = $http->get(SystemEnvironment::proxyUrl('/api/public/clinics'));

        if ($response->getStatusCode() === 200) {
            $successfulRequests++;

            continue;
        }

        $limited = $response;
        break;
    }

    expect($successfulRequests)->toBeGreaterThan(0)
        ->and($limited)->not->toBeNull()
        ->and($limited->getStatusCode())->toBe(429)
        ->and(systemJsonResponse($limited)['message'] ?? null)
        ->toBe('Demasiadas solicitudes. Inténtalo de nuevo más tarde.');
});

it('serves the application through Caddy with the configured security headers', function () {
    $response = SystemEnvironment::http()->get(SystemEnvironment::proxyUrl('/'));
    $headers = $response->getHeaders();
    $csp = SystemEnvironment::header($headers, 'Content-Security-Policy');

    expect($response->getStatusCode())->toBe(200)
        ->and($csp)->not->toBeNull()
        ->and($csp)->toContain("default-src 'self'")
        ->and($csp)->toContain("frame-ancestors 'none'")
        ->and(SystemEnvironment::header($headers, 'X-Frame-Options'))->toBe('DENY')
        ->and(SystemEnvironment::header($headers, 'Strict-Transport-Security'))
        ->toBe('max-age=31536000')
        ->and(SystemEnvironment::header($headers, 'X-Content-Type-Options'))->toBe('nosniff')
        ->and(SystemEnvironment::header($headers, 'Referrer-Policy'))
        ->toBe('strict-origin-when-cross-origin')
        ->and(SystemEnvironment::header($headers, 'Permissions-Policy'))
        ->toBe('camera=(), microphone=(), geolocation=()');
});
