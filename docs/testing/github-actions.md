# Integración continua con GitHub Actions

El workflow `.github/workflows/ci.yml` comprueba automáticamente el backend y el
frontend de MediNet en cada `push` y `pull_request` dirigido a `main`. También se
puede ejecutar manualmente desde **Actions > Pruebas automatizadas > Run workflow**.

## Qué valida

- **Backend (Laravel + PostgreSQL):** instala Composer, crea una base PostgreSQL
  temporal, ejecuta todas las migraciones y corre las pruebas de PHPUnit.
- **Frontend (Flutter):** instala paquetes, ejecuta el análisis estático, corre
  todas las pruebas de Flutter y verifica que la aplicación web compile.

Los dos trabajos se ejecutan en paralelo. Un cheque verde significa que todos
los pasos terminaron correctamente; uno rojo indica qué paso y prueba fallaron.

## Reportes y logs

Al finalizar una ejecución, incluso si falla una prueba, GitHub conserva durante
30 días los artefactos disponibles al final de la página:

- `reporte-backend-N`: reporte JUnit XML de PHPUnit.
- `reporte-frontend-N`: salida estructurada JSON de `flutter test`.

Los detalles de cada comando también quedan en el log desplegable del trabajo.

## Evidencias solicitadas para la tarea

1. **Ejecución exitosa:** subir el workflow y tomar una captura de los dos
   trabajos en verde.
2. **Regresión detectada:** crear una rama temporal, modificar deliberadamente
   una expectativa de una prueba existente y abrir un pull request. Capturar el
   trabajo rojo y el mensaje donde aparece la prueba que falló.
3. **Corrección verificada:** restaurar la expectativa correcta y subir otro
   commit al mismo pull request. Capturar la nueva ejecución en verde.

No se debe introducir el fallo deliberado en `main`. Se hace únicamente en una
rama temporal y se corrige antes de integrar el pull request.

## Demostración sugerida

Para evidenciar un fallo sin alterar el código de producción, puede cambiarse
temporalmente una expectativa en cualquier archivo dentro de `frontend/test/`.
Después de capturar la ejecución fallida, se restaura el archivo con Git, se
crea el commit de corrección y se vuelve a subir la rama.

Los secretos reales no se guardan en el workflow. La base de datos y las demás
variables utilizadas en CI son datos temporales exclusivos de cada ejecución.
