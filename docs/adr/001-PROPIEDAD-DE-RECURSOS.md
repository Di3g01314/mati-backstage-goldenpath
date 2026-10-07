# ADR-001 · Separar cimientos, reconciliación y experiencia de usuario

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

El clúster debe existir antes de instalar sus controladores; la solicitud de cada equipo debe conservar autoservicio y corrección de drift.

## Decisión

Terraform administra cimientos y RDS del portal; Argo CD los componentes Kubernetes; Crossplane las RDS solicitadas. Backstage produce repositorios y contratos. Ningún recurso AWS debe tener dos propietarios declarativos.

## Alternativas consideradas

Un único Terraform por solicitud simplificaría herramientas, pero necesitaría un ejecutor y estado por flujo. Provisionar desde Backstage directamente acoplaría la experiencia a credenciales y lógica AWS. Argo sin Crossplane no administra por sí solo la instancia RDS.

## Consecuencias y límites

Se agrega complejidad de controladores a cambio de una API interna y reconciliación continua. Hay que coordinar bootstrap, permisos y orden de retirada. Un plan Terraform no comprueba la parte administrada por Crossplane.

## Cuándo revisar

Cuando el costo operativo de los controladores supere el beneficio de autoservicio o cambie el proveedor de infraestructura.

## Trazabilidad

- [main.tf](../../terraform/main.tf)
- [database.yaml](../../platform/charts/config/templates/database.yaml)

[Volver al índice](README.md)
