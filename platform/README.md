# Plataforma GitOps

`charts/bootstrap` instala AppProjects y Applications. `charts/config` se renderiza en etapas `runtime`, `resources`, `backstage`, `applicationsets`; `all` se usa en validación local. Los valores reales se exportan desde outputs de Terraform a `.generated/platform-values.yaml` y nunca se versionan.

Versiones en `versions.yaml`, esquemas externos con SHA256 en `schemas.lock.json`. La infraestructura del piloto se origina en `gitops/tenants/piloto/<servicio>/`; cada servicio tiene su propio repositorio privado. Las bases quedan retenidas por diseño al retirar la solicitud.

Consultar [arquitectura](../docs/ARQUITECTURA.md), [operación](../docs/PREPARACION-DESPLIEGUE.md) y [validación](../docs/VALIDACION.md). Los valores de `tests/fixtures/platform.yaml` son ficticios y solo sirven para render.
