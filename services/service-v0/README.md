# Contrato del servicio v0 (pendiente de implementación)

Imagen genérica para la primera entrega del Golden Path. Debe leer PGHOST, PGPORT, PGDATABASE, PGUSER y PGPASSWORD desde un Secret único por servicio y requerir TLS para PostgreSQL.

- `GET /healthz`: proceso vivo, sin dependencia de DB.
- `GET /readyz`: comprueba conexión y SELECT 1; 200 si conecta, 503 si no.
- `GET /`: respuesta legible con nombre del servicio, versión y estado conectado; jamás imprimir contraseña o cadena de conexión completa.

Incluir timeout, reintentos acotados al arrancar, ejecución sin root, requests/limits y probes. Si RDS todavía no está disponible, readiness debe fallar sin reinicios continuos por liveness. Probar con PostgreSQL local antes de publicar la imagen en ECR.

El build/publicación inicial está pendiente. Este README no constituye una aplicación funcional.
