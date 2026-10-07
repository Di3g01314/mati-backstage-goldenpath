# Catálogo

Las entidades activas están en `backstage/catalog/entities.yaml`. Incluyen el sistema GoldenPath, el equipo piloto y el usuario autorizado de GitHub. La plantilla está en `backstage/templates/microservice/template.yaml`.

Cada solicitud produce un Component con dueño, sistema, repositorio y anotaciones Kubernetes que acotan la consulta al namespace del piloto. Las altas remotas se realizan mediante la acción controlada `goldenpath:register`; los usuarios no pueden importar plantillas arbitrarias.
