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
| Fronteras autenticadas | Pest y API Laravel | Consultar citas, usuarios, listas de espera, notificaciones y preferencias, además de intentar crear una cita pública, sin token | Las seis operaciones responden 401 antes de acceder a datos protegidos |
| Identidad Supabase activa | Pest, mock HTTP de Supabase, middleware y PostgreSQL | Enviar un token reconocido cuyo `sub` corresponde a un usuario local activo | `/api/profile` resuelve al usuario correcto y no expone `supabase_id` |
| Usuarios inactivos | Pest, mock HTTP de Supabase, middleware y PostgreSQL | Supabase acepta el token, pero `users.is_active` es falso | La API rechaza el acceso con HTTP 403 |
| Enlace de identidad por `sub` | Pest, mock HTTP de Supabase, middleware y PostgreSQL | El correo coincide con un usuario local, pero el `sub` de Supabase es diferente | La API rechaza el acceso; no existe fallback inseguro por correo |
| Aislamiento de usuarios | Pest, API Laravel, policies y PostgreSQL | Un paciente consulta su propio `/api/users/{id}` y luego el ID de otro usuario | Puede ver únicamente su registro y recibe HTTP 403 para el ajeno |
| Identidad y aislamiento de citas | Pest, API Laravel, policies y PostgreSQL | Enviar identidad falsificada al crear una cita y luego intentar listar, consultar, cancelar y eliminar una cita ajena | La cita toma la identidad autenticada; el listado omite la cita ajena y las operaciones directas reciben HTTP 403 sin eliminarla |
| Límite de solicitudes | Pest, Caddy, API Laravel y cache en PostgreSQL | Repetir una búsqueda pública desde el mismo origen | El contador persiste entre requests y la API finalmente responde HTTP 429 con el contrato esperado |
| Headers de seguridad | Pest, Caddy y frontend | Solicitar `/` a través del proxy usado en producción | Se reciben CSP, anti-clickjacking, HSTS, `nosniff`, Referrer Policy y Permissions Policy |

## Casos de regresión

| Funcionalidad protegida | Modificación que podría causar la regresión | Resultado esperado |
|---|---|---|
| El endpoint público de salud conserva `{"message":"pong"}` | Cambiar la respuesta de la ruta o apuntar `/api` al servicio incorrecto | HTTP 200 y el JSON exacto |
| Las rutas directas de Flutter usan el fallback SPA de nginx | Eliminar `try_files ... /index.html` de `frontend/nginx.conf` | `/register` entrega el mismo shell HTML que `/`, no un 404 |
| Las solicitudes autenticadas conservan un preflight CORS válido | Restringir métodos/headers necesarios o eliminar `HandleCors` | `OPTIONS /api/profile` devuelve 204 para `SYSTEM_BROWSER_ORIGIN` y permite `GET`, `Authorization`, `Content-Type`, `Cache-Control` y `Pragma` |
| Los orígenes externos no reciben autorización CORS | Volver a permitir `*` o agregar patrones demasiado amplios | Un preflight desde `https://attacker.example` no recibe `Access-Control-Allow-Origin` |

## Ejecución con Compose

Primero se levantan los componentes reales con el overlay de seguridad. Este
overlay usa un mock HTTP de Supabase y el volumen aislado
`medinet_security_postgres_data`, por lo que `migrate:fresh` no modifica la base
local de desarrollo:

```bash
docker compose --env-file .github/ci/backend.env \
  -f docker-compose.yml -f docker-compose.security.yml \
  up -d --build --wait db backend reverb frontend security-proxy

docker compose --env-file .github/ci/backend.env \
  -f docker-compose.yml -f docker-compose.security.yml \
  exec -T backend php artisan migrate:fresh --force
```

Las 20 pruebas del sistema (16 de integración y 4 de regresión) se ejecutan
desde el contenedor backend:

```bash
docker compose --env-file .github/ci/backend.env \
  -f docker-compose.yml -f docker-compose.security.yml \
  exec -T backend php vendor/bin/pest \
  --configuration=phpunit.system.xml --do-not-cache-result
```

También se puede ejecutar una sola suite:

```bash
docker compose --env-file .github/ci/backend.env \
  -f docker-compose.yml -f docker-compose.security.yml \
  exec -T backend php vendor/bin/pest --configuration=phpunit.system.xml \
  --testsuite=Integration

docker compose --env-file .github/ci/backend.env \
  -f docker-compose.yml -f docker-compose.security.yml \
  exec -T backend php vendor/bin/pest --configuration=phpunit.system.xml \
  --testsuite=Regression
```

Los valores predeterminados asumen que Pest corre dentro de la red Compose. Se
pueden sobrescribir las siguientes variables para otro entorno:

- `SYSTEM_BACKEND_URL` (predeterminado `http://backend:8000`)
- `SYSTEM_FRONTEND_URL` (predeterminado `http://frontend`)
- `SYSTEM_REVERB_URL` (predeterminado `http://reverb:8080`)
- `SYSTEM_PROXY_URL` (predeterminado `http://security-proxy:8080`)
- `SYSTEM_EXPECTED_API_URL` (predeterminado `https://medinet.lat/api`)
- `SYSTEM_BROWSER_ORIGIN` (predeterminado `http://localhost:3055`)
- `SYSTEM_DB_HOST`, `SYSTEM_DB_PORT`, `SYSTEM_DB_DATABASE`,
  `SYSTEM_DB_USERNAME` y `SYSTEM_DB_PASSWORD`

Las pruebas que crean fixtures los eliminan al terminar. Aun así, deben correr
contra el volumen aislado definido en `docker-compose.security.yml`, nunca
contra una base con datos de desarrollo o producción.

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
