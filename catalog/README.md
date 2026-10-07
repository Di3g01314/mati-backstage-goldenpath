# Contrato del catálogo (pendiente)

Registrar grupos/equipos y el Component por servicio, con owner válido, repo, descripción, ambiente dev y referencias a Argo CD/Kubernetes. El centro de costo debe venir del equipo o configuración administrada, no convertirse en un quinto campo del formulario.

Los cuatro campos son: nombre del servicio, equipo dueño, tamaño de base (pequeña/mediana), descripción. El formulario genera código, manifiestos de servicio y PR GitOps. La plataforma deriva el namespace desde el equipo y usa nombres únicos por servicio para base y Secret.

Falta implementar el portal, template, catálogo y lectura del estado real; no se fabrican estados Ready para la demo.
