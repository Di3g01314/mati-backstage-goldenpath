# Decisiones de arquitectura

Un ADR registra por qué se eligió una opción y qué consecuencias se aceptaron. “Adoptada” significa que está reflejada en código, no que haya sido validada de extremo a extremo en AWS.

| Decisión | Tema | Estado |
|---|---|---|
| ADR-001 | [Separar cimientos, reconciliación y experiencia de usuario](001-PROPIEDAD-DE-RECURSOS.md) | Adoptada en código; validación AWS pendiente |
| ADR-002 | [Un EKS y un namespace por equipo para la PoC](002-UN-EKS-Y-NAMESPACE-POR-EQUIPO.md) | Adoptada en código; validación AWS pendiente |
| ADR-003 | [URL HTTPS de API Gateway y autenticación en Backstage](003-ENTRADA-Y-AUTENTICACION.md) | Adoptada en código; validación AWS pendiente |
| ADR-004 | [Separar OAuth de usuario y credencial de automatización](004-INTEGRACION-GITHUB.md) | Adoptada en código; validación AWS pendiente |
| ADR-005 | [Un contrato PostgreSQL limitado y bases retenidas](005-CONTRATO-POSTGRESQL-Y-RETENCION.md) | Adoptada en código; validación AWS pendiente |
| ADR-006 | [Fusionar solo solicitudes estándar validadas como datos](006-SOLICITUDES-GITOPS-COMO-DATOS.md) | Adoptada en código; validación AWS pendiente |
| ADR-007 | [Validación sin AWS y despliegue inicial controlado](007-ENTREGA-Y-RECUPERACION.md) | Adoptada en código; validación AWS pendiente |

Para una decisión nueva: copiar contexto, decisión, alternativas, consecuencias, criterio de revisión y enlaces al código. Si sustituye otra, registrar la relación sin borrar la anterior. No usar el ADR para presentar una propuesta futura como funcionalidad implementada.
