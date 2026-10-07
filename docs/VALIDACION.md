# Evidencias de validación previa

Validación local del 6 de octubre de 2026 (America/Bogota), sin aplicar recursos AWS.

| Comprobación | Resultado |
|---|---|
| Terraform fmt, init sin backend, validate | Correcto en entorno, módulo Pod Identity y bootstrap-state |
| Terraform test | 7/7 con AWS simulado, solo plan |
| Plan real con consultas AWS | 102 creaciones, 0 cambios, 0 eliminaciones; completo y aplicable según Terraform |
| Versiones AWS | EKS 1.35/add-ons y PostgreSQL 16.15 consultados en us-east-1 |
| Política GitOps | 7/7: contrato válido y rechazo de tamaño, owner/cost-center, namespace, overrides y archivos extra |
| Helm y Crossplane | Ambos charts renderizan; pipeline real genera los dos tamaños y valida esquemas RDS/PodIdentity fijados |
| Kubernetes local | Dry-run servidor de plataforma, Applications, servicio y RDS; Kyverno acepta válido y rechaza owner, costo y tamaño inválidos |
| Backstage | TypeScript y build; backend real devuelve 401 sin login y 403 al alta arbitraria de catálogo |
| Scaffolder | Dry-run real genera 12 archivos; conserva descripción con comillas, sin publicar GitHub/AWS |
| Servicio v0 | 3 pruebas unitarias; PostgreSQL real con TLS verificado, caída 503, liveness 200 y recuperación 200 |
| Imágenes | Servicio y Backstage construidos localmente; publicación ECR pendiente |

Los logs, planes, variables reales y archivos generados se conservan localmente en rutas ignoradas. No se publican estados ni tokens como evidencia. El clúster kind creado para admisión se retiró al terminar; no se alteró el clúster local preexistente del usuario.

## Alcance de la evidencia

El Kubernetes local era 1.37; el destino AWS es 1.35. Se verificaron esquemas y admisión, no la ejecución de los controladores AWS. El CRD SecurityGroupPolicy de VPC CNI no estaba instalado en la prueba de servidor local; esa integración requiere comprobación en EKS.

Pendiente de despliegue: permisos efectivos de creación, cuotas/capacidad, Pod Identity, red de EKS/ambient/SGP, callbacks y cookies vía API Gateway, entrega de secretos real, creación de repositorios con el token final y el Golden Path completo hasta RDS Ready. El tiempo prometido en la presentación es una meta, no un resultado medido.

La base inicial tenía CI verde. La ejecución del CI del cambio actual debe consultarse en su PR; esta tabla registra las pruebas locales y no sustituye el resultado de GitHub Actions.
