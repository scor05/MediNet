# Pruebas Pest entre contenedores

Estas suites llaman a los servicios Docker en ejecución mediante sus endpoints
reales. No son pruebas unitarias ni reemplazan PostgreSQL, nginx o Reverb con
mocks.

## Casos de integración

| Prueba | Componentes involucrados | Condición y datos necesarios | Resultado esperado |
|---|---|---|---|
| API pública y persistencia | Pest, API Laravel y PostgreSQL | Solicitar `GET /api/public/doctors` y consultar en la base real las relaciones activas entre `users`, `client_users`, `schedules` y `clinics` | HTTP 200 y exactamente los mismos IDs de doctores en la API y PostgreSQL |
| Artefacto frontend y API | Pest, nginx, bundle compilado de Flutter y API Laravel | Solicitar `/`, `/main.dart.js` y `/api/ping`; `SYSTEM_EXPECTED_API_URL` define el contrato del build | nginx entrega HTML y JavaScript, el bundle contiene la URL esperada y la API responde |
| Backend y WebSocket | Pest dentro de la red Compose y Laravel Reverb | Solicitar el health check `/up` del servicio `reverb:8080` | HTTP 200 del proceso Reverb real |

## Casos de regresión

| Funcionalidad protegida | Modificación que podría causar la regresión | Resultado esperado |
|---|---|---|
| El endpoint público de salud conserva `{"message":"pong"}` | Cambiar la respuesta de la ruta o apuntar `/api` al servicio incorrecto | HTTP 200 y el JSON exacto |
| Las rutas directas de Flutter usan el fallback SPA de nginx | Eliminar `try_files ... /index.html` de `frontend/nginx.conf` | `/register` entrega el mismo shell HTML que `/`, no un 404 |
| Las solicitudes autenticadas conservan un preflight CORS válido | Restringir métodos/headers necesarios o eliminar `HandleCors` | `OPTIONS /api/profile` devuelve 204 y permite `GET`, `Authorization`, `Content-Type`, `Cache-Control` y `Pragma` |

## Ejecución con Compose

Primero se levantan los componentes reales:

```bash
docker compose --env-file backend/.env up -d --build db backend reverb frontend
```

Las seis pruebas se ejecutan desde el contenedor backend:

```bash
docker compose --env-file backend/.env exec backend \
  php vendor/bin/pest --configuration=phpunit.system.xml
```

También se puede ejecutar una sola suite:

```bash
docker compose --env-file backend/.env exec backend \
  php vendor/bin/pest --configuration=phpunit.system.xml \
  --testsuite=Integration

docker compose --env-file backend/.env exec backend \
  php vendor/bin/pest --configuration=phpunit.system.xml \
  --testsuite=Regression
```

Los valores predeterminados asumen que Pest corre dentro de la red Compose. Se
pueden sobrescribir las siguientes variables para otro entorno:

- `SYSTEM_BACKEND_URL` (predeterminado `http://backend:8000`)
- `SYSTEM_FRONTEND_URL` (predeterminado `http://frontend`)
- `SYSTEM_REVERB_URL` (predeterminado `http://reverb:8080`)
- `SYSTEM_EXPECTED_API_URL` (predeterminado `https://medinet.lat/api`)
- `SYSTEM_BROWSER_ORIGIN` (predeterminado `http://localhost:3055`)
- `SYSTEM_DB_HOST`, `SYSTEM_DB_PORT`, `SYSTEM_DB_DATABASE`,
  `SYSTEM_DB_USERNAME` y `SYSTEM_DB_PASSWORD`

La prueba de PostgreSQL es de solo lectura.

## Demostración deliberada de regresión

Se cambió temporalmente el mensaje de `/api/ping` de `pong` a
`regression-demo`. La suite produjo:

```text
Tests: 1 failed, 2 passed (13 assertions)
Expected: ['message' => 'pong']
Actual:   ['message' => 'regression-demo']
```

Después de restaurar `pong`, se ejecutó la misma suite:

```text
Tests: 3 passed (13 assertions)
```

El defecto deliberado quedó corregido y no forma parte del estado final.
