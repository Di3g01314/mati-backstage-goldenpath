# Solicitudes GitOps

Aquí escribe el scaffolder, en `piloto/<servicio>/`. Cada solicitud añade únicamente `database.yaml` y `service.json`. La CI verifica el contrato y el scaffolder fusiona el PR después de un check exitoso para ese SHA.
