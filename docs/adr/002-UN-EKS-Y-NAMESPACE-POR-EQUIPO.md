# ADR-002 · Un EKS y un namespace por equipo para la PoC

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

El primer piloto requiere un entorno de desarrollo limitado, con costos y operación razonables para una demostración.

## Decisión

Usar una cuenta, un EKS y namespaces separados para plataforma y equipo piloto. El namespace del piloto se prepara en bootstrap; cada servicio obtiene recursos dentro de él. Configurar cuotas, RBAC/AppProjects, red y SGP.

## Alternativas consideradas

Un clúster por equipo y hub/spokes multicuenta mejora aislamiento, pero multiplica costos y operación. Un namespace por servicio agrega objetos y políticas sin ser necesario para este único piloto.

## Consecuencias y límites

Gestión y cargas comparten capacidad y dominio de falla. Namespace no equivale a cuenta o clúster aislado. El dimensionamiento de dos t3.large está por validar bajo carga; no se garantiza alta disponibilidad.

## Cuándo revisar

Antes de incorporar producción, equipos con fronteras de confianza distintas o cargas que requieran disponibilidad independiente.

## Trazabilidad

- [main.tf](../../terraform/main.tf)
- [teams.yaml](../../platform/charts/config/templates/teams.yaml)
- [projects.yaml](../../platform/charts/bootstrap/templates/projects.yaml)

[Volver al índice](README.md)
