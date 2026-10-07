# ADR-005 · Un contrato PostgreSQL limitado y bases retenidas

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

La TVP reemplaza el ticket de una base relacional sin obligar al desarrollador a elegir motor, subredes, cifrado o políticas de respaldo.

## Decisión

Exponer PostgreSQLInstance namespaced con tamaño pequena/mediana; la Composition fija PostgreSQL, subredes, cifrado y respaldo. Crossplane entrega el Secret de conexión. La base piloto excluye Delete y mantiene deletionProtection.

## Alternativas consideradas

Exponer todos los parámetros RDS aumenta carga cognitiva y errores. Una base compartida reduce costo pero cambia aislamiento y propiedad. Borrado automático facilita limpieza, pero eleva el riesgo de pérdida accidental.

## Consecuencias y límites

Hay límites claros de costo/capacidad y una ruta de conexión estable. La retención exige baja explícita y puede generar costos después de borrar un servicio. No se incluye restauración automática ni garantía de disponibilidad.

## Cuándo revisar

Al definir una política de expiración, múltiples ambientes, nuevos motores o un procedimiento de restauración ensayado.

## Trazabilidad

- [database.yaml](../../platform/charts/config/templates/database.yaml)
- [deployment.yaml](../../backstage/templates/microservice/skeleton/deploy/deployment.yaml)

[Volver al índice](README.md)
