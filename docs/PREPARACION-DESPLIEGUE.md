# Trabajo pendiente antes del primer despliegue

Estado: no autorizado para desplegar. No se han ejecutado apply, destroy, bootstrap ni restauraciones. La preparación actual solo descarga herramientas/proveedores y valida código.

## Datos del entorno

- [ ] Confirmar cuenta AWS, región, propietario, centro de costo y presupuesto máximo para la PoC.
- [ ] Verificar CIDR y disponibilidad de tres AZs; mantener recursos independientes de reference.
- [ ] Elegir versión EKS en soporte estándar y fijar versiones compatibles de CoreDNS, kube-proxy, VPC CNI y Pod Identity agent. No heredar Kubernetes 1.31 automáticamente.
- [ ] Elegir una versión menor disponible de PostgreSQL 16 y confirmar db.t4g.micro en la región.
- [ ] Definir roles IAM existentes para administración y para la futura CI; no crear usuarios humanos con AdministratorAccess.
- [ ] Preparar un backend S3 cifrado, versionado y exclusivo de GoldenPath, con bloqueo y permisos mínimos. `backend.tf.example` no crea el bucket.
- [ ] Definir el acceso al endpoint privado de EKS. Si se habilita endpoint público, restringir CIDRs administrativos explícitos.

## Integraciones que todavía faltan

- [ ] GitHub App para Backstage: repositorios autorizados, webhook y permisos mínimos para creación, PR y catálogo.
- [ ] Repositorio GitOps dedicado y separación de permisos entre plataforma y servicios. La base actual puede albergar los cimientos, pero no sustituye esa frontera de permisos.
- [ ] Argo CD: AppProjects restringidos por namespace/tipo de recurso y ApplicationSets que separen infraestructura de aplicación.
- [ ] Backstage: app, imagen, charts, autenticación, catálogo, equipos y template de cuatro campos.
- [ ] Crossplane v2: versiones de chart/provider/function, XRD, Composition, Pod Identity y permisos RDS específicos.
- [ ] External Secrets: acceso a la contraseña de Backstage; entrega de Secret del piloto según el provider de Crossplane elegido.
- [ ] Kyverno y políticas de red: owner/cost-center/tamaño, cuotas, denegación por defecto y permisos explícitos.
- [ ] Resolver portal-edge: OIDC/cookies/callbacks, WAF, TLS y routing de Backstage; no exponerlo con autenticación anónima.
- [ ] Implementar y publicar servicio v0 que haga SELECT 1 sin devolver credenciales.
- [ ] Definir acceso controlado al servicio v0 para la demo, sin convertir todos los servicios en endpoints públicos.

## Costos y ciclo de vida

- [ ] Estimar EKS, workers, NAT, IPv4 pública, NLB, RDS, almacenamiento, logs, secretos y transferencia con precios de la fecha de despliegue.
- [ ] Definir ventana de encendido y alerta presupuestal. El tiempo de grabación no es el único tiempo facturable.
- [ ] Resolver borrado: la RDS está protegida y exige snapshot final; desmontar recursos de Crossplane/Argo antes de retirar EKS. Destruir cimientos primero puede dejar recursos huérfanos.
- [ ] Acordar retención de backups, logs, ECR y estado; retirar protección RDS solo durante un apagado autorizado y probado.
- [ ] Ensayar medición real del Golden Path, fallos, reintentos y reconciliación. La meta de 10–15 minutos no está comprobada.

## Secuencia posterior

Cerrar los puntos anteriores, integrar GitOps y servicio v0, revisar el plan en la cuenta destino y obtener autorización explícita de despliegue. Solo entonces habilitar `deployment_enabled`. No se modifican variables de despliegue desde CI.
