# Plataforma GitOps pendiente

Esta carpeta reserva el contrato de integración; todavía no contiene manifiestos aplicables.

Estructura futura: bootstrap app-of-apps; Argo CD; Backstage; Crossplane v2 (provider RDS, function, XRD y Composition); Kyverno; External Secrets; Istio ambient; namespaces de equipos y ApplicationSets.

Cada servicio requiere dos Applications y fuentes Git distintas. Los repositorios de los equipos no pueden declarar Namespace, PostgreSQLInstance ni recursos de plataforma. AppProjects y RBAC deben impedirlo efectivamente: no basta que la plantilla genere un namespace correcto.

GitOps del piloto: namespace del equipo, PostgreSQLInstance con nombre único por servicio, metadatos owner/cost-center y descriptor que asocia servicio, equipo y repoURL. No confundir nombre de servicio con namespace de equipo; varios servicios del mismo equipo deben compartir el namespace sin sobrescribir Secrets.
