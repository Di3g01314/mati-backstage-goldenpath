# Servicio v0

Servicio HTTP Node.js con PostgreSQL. `GET /healthz` indica liveness. `GET /readyz` y `GET /` ejecutan SELECT 1 y devuelven 200 si PostgreSQL responde, o 503 sin revelar errores/credenciales. La conexión verifica TLS contra el bundle público de Amazon RDS.

Configuración: variables estándar PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE; SERVICE_NAME y SERVICE_VERSION. Los manifiestos generados toman las cuatro primeras del Secret de Crossplane y usan PGDATABASE=app. PGSSLMODE=disable solo se permite fuera de producción.

`npm ci && npm test` ejecuta pruebas unitarias. `python3 ../../scripts/test-service-integration.py` comprueba una base real, TLS, caída y recuperación en contenedores locales. La plantilla Backstage incluye el mismo código y un CI de Node. La imagen genérica v1 se publica una vez con el script operativo de plataforma.
