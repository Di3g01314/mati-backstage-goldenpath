# ADR-007 · Validación sin AWS y despliegue inicial controlado

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

El usuario pidió preparar y validar la implementación sin desplegar. Una futura plataforma necesita cambios trazables y una ruta de recuperación.

## Decisión

CI valida sin credenciales AWS; plan, apply, imágenes y bootstrap se separan en scripts. La operación que escribe requiere cuenta esperada y gate explícito. Tras bootstrap, Argo reconcilia charts y servicios desde main.

## Alternativas consideradas

Apply automático en cada push reduce pasos pero excede el alcance actual y exige controles de identidad/aprobación. Un pipeline completo de promoción entre ambientes requeriría entornos que todavía no existen.

## Consecuencias y límites

Una fusión puede cambiar Kubernetes cuando Argo esté activo. El bootstrap Helm no es una raíz app-of-apps administrada por Argo. El script de imágenes publica v1; una nueva release debe parametrizarlo/actualizarlo y cambiar valores sin sobrescribir el tag. Revertir código no restaura datos.

## Cuándo revisar

Antes del primer cambio posterior a la demo: definir promoción, versionado de imágenes, protección de ramas y rollback probado.

## Trazabilidad

- [ci.yml](../../.github/workflows/ci.yml)
- [require-deployment-authorization.sh](../../scripts/require-deployment-authorization.sh)
- [publish-images.sh](../../scripts/publish-images.sh)
- [bootstrap-platform.sh](../../scripts/bootstrap-platform.sh)

[Volver al índice](README.md)
