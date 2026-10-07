# Documentación de GoldenPath

Punto de entrada para el equipo y la sustentación. **El despliegue autorizado en AWS está en curso desde el 7 de octubre de 2026.** El [registro de despliegue](DESPLIEGUE-AWS.md) distingue los recursos ya creados de las integraciones y pruebas que siguen pendientes. Todavía no se ha validado el portal ni la PoC completa en AWS. Cada documento distingue configuración existente, resultado probado y evolución propuesta.

## Empieza aquí

1. [Guía del equipo](GUIA-EQUIPO.md): clonar, ejecutar localmente, validar y contribuir.
2. [Diagnóstico y alcance](DIAGNOSTICO-Y-ALCANCE.md): problema, prioridad, TVP y métricas.
3. [Arquitectura general](ARQUITECTURA.md) y [cuatro vistas operativas](vistas/README.md): cómo encajan los componentes.
4. [Decisiones de arquitectura](adr/README.md): razones, alternativas y consecuencias.
5. [APIs y evolución](APIS-Y-EVOLUCION.md): contrato del servicio y servicios futuros del portal.
6. [Costos](COSTOS.md) y [operación](OPERACION.md): dimensionamiento, diagnóstico de fallos y cierre.
7. [Evidencias de aceptación](EVIDENCIAS-ACEPTACION.md): qué está probado y qué debe registrarse al desplegar.

## Guías existentes

| Necesidad | Documento |
|---|---|
| Preparar el primer despliegue | [Secuencia y prerrequisitos](PREPARACION-DESPLIEGUE.md) |
| Comprender CI, política de PR y entrega | [CI/CD](CI-CD.md) |
| Consultar las pruebas ya realizadas | [Validación](VALIDACION.md) |
| Contrastar guía y rúbrica | [Cobertura del proyecto](COBERTURA-PROYECTO.md) |
| Grabar la demostración | [Guion del video](DEMO.md) |
| Revisar la adaptación de módulos | [Inventario](INVENTARIO-REUTILIZACION.md) y [procedencia](PROVENANCE.json) |

## Mantener estos documentos

Cada PR que cambie contratos, permisos, red o ciclo de vida debe actualizar el documento correspondiente. Para una decisión estructural, agregar un ADR y enlazarlo desde su índice. Conservar el historial de decisiones sustituidas. Las evidencias deben identificar fecha, commit, entorno y resultado; un objetivo no se registra como resultado.

El repositorio es público. Usar nombres y ejemplos genéricos para evidencias empresariales; los datos reales de cuenta, tokens, estados y planes permanecen fuera del repositorio.
