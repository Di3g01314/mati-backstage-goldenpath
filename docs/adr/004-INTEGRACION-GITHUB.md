# ADR-004 · Separar OAuth de usuario y credencial de automatización

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

El repositorio de plataforma y los repositorios generados viven bajo una cuenta personal de GitHub. Login y operaciones de repositorio requieren capacidades distintas.

## Decisión

Preparar GitHub OAuth para identidad del usuario y un PAT de integración para creación de repositorios/PR. Guardar ambos en Secrets Manager y entregarlos mediante ESO. Verificar pertenencia al equipo en las acciones; el PAT no viaja al frontend.

## Alternativas consideradas

Una GitHub App en una organización permite permisos y repositorios acotados. Usar tokens individuales para cada desarrollador complica el onboarding del piloto. Cambiar a una organización requiere preparar su gobierno e integración.

## Consecuencias y límites

El PAT concede un alcance importante sobre la cuenta; se requiere dedicación, vencimiento y rotación. El nombre técnico github-app del secreto no indica que se haya instalado una GitHub App. No se han cargado credenciales reales.

## Cuándo revisar

Al pasar a una organización o ampliar los equipos. Evaluar App e instalación mínima antes de ampliar el alcance del token.

## Trazabilidad

- [app-config.production.yaml](../../backstage/app-config.production.yaml)
- [goldenpath.ts](../../backstage/packages/backend/src/modules/goldenpath.ts)
- [secrets.yaml](../../platform/charts/config/templates/secrets.yaml)

[Volver al índice](README.md)
