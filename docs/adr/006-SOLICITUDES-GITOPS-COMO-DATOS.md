# ADR-006 · Fusionar solo solicitudes estándar validadas como datos

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

El autoservicio no debe necesitar aprobación humana por cada base ni permitir que una solicitud cambie la plataforma.

## Decisión

La plantilla agrega exactamente dos archivos. pull_request_target ejecuta código del SHA base confiable y valida contenido por API, sin ejecutar código del PR. La acción merge exige repo/rama/base esperados y check exitoso de GitHub Actions para el SHA actual.

## Alternativas consideradas

Revisión manual en cada solicitud mantiene la espera que se pretende eliminar. Ejecutar código del PR en un workflow con permisos de escritura permite modificar el validador. Un check de una versión anterior no valida el contenido actual.

## Consecuencias y límites

El contrato es rígido y cambios de tamaño posteriores no entran en la ruta de alta automática. Los administradores y autores del workflow siguen siendo una frontera de confianza. Kyverno agrega defensa en admisión, no reemplaza la política de Git.

## Cuándo revisar

Al agregar modificaciones/bajas, más equipos o un modelo de permisos que permita validar responsables desde un directorio corporativo.

## Trazabilidad

- [goldenpath-policy.yml](../../.github/workflows/goldenpath-policy.yml)
- [validate-request.py](../../scripts/validate-request.py)
- [goldenpath.ts](../../backstage/packages/backend/src/modules/goldenpath.ts)

[Volver al índice](README.md)
