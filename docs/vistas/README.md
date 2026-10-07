# Cuatro vistas operativas

Los diagramas describen la configuración de la PoC que existe en el repositorio. No representan infraestructura AWS ya desplegada. GitHub renderiza los bloques Mermaid y permite mantener los diagramas junto al código.

| Vista | Pregunta que responde |
|---|---|
| [1. Ubicación física](01-UBICACION-FISICA.md) | ¿Dónde viven gestión, cargas y datos? |
| [2. Red y Zero-Trust](02-RED-Y-CONFIANZA.md) | ¿Qué se comunica, por qué ruta y con qué controles? |
| [3. Control y eventos](03-CONTROL-Y-EVENTOS.md) | ¿Cómo pasa una solicitud de Git a un recurso listo? |
| [4. Ciclo de vida](04-CICLO-DE-VIDA.md) | ¿Cómo cambia, se valida y se recupera la plataforma? |

Complementar con [arquitectura general](../ARQUITECTURA.md), [ADRs](../adr/README.md) y [evidencias](../EVIDENCIAS-ACEPTACION.md). La topología multicuenta/multiclúster es una evolución propuesta, no parte del primer despliegue.
