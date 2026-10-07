<?php

use Tests\Support\SystemEnvironment;

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
