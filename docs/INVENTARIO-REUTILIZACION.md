# Inventario de reutilización

Revisión: 6 de octubre de 2026 (America/Bogota).
Origen privado: [mati-arq-nueva-gen-reference-iac](private-reference-repository), commit `87979b5da7dba036f9917152ca8af5faa68ba1b0`.

El origen tiene una única configuración Terraform distribuida en archivos; no tenía módulos hijos. Aquí se extraen sus recursos y se establecen entradas/salidas explícitas. No es una migración del estado original: los futuros recursos de GoldenPath serán nuevos.

| Origen | Destino / decisión | Adaptación |
|---|---|---|
| `terraform/network.tf` | `modules/network` | Conserva VPC/NAT/red privada; añade subredes de datos sin salida por NAT o IGW |
| `terraform/eks.tf` | `modules/eks` | Quita cuentas y KMS retenidas; KMS propia; API privada por defecto; versiones obligatorias; añade requisito de Pod Identity agent |
| `terraform/rds.tf` | `modules/rds-postgres` | Una base para Backstage; elimina réplica y restauración de reference; privada, gp3, contraseña administrada y protección de borrado |
| `terraform/ecr.tf` | `modules/ecr` | Repositorios nuevos parametrizados; elimina búsquedas de los ECR retenidos; tags inmutables |
| `terraform/api.tf` | `modules/portal-edge` | Conserva HTTP API/VPC Link/NLB/NodePort; autenticación IAM, límites de tráfico menores y reglas SG explícitas; opcional |
| `terraform/data.tf` | Entradas de módulos | Elimina lectura de secretos y llaves de la cuenta anterior |
| `terraform/iam-users.tf` | Excluido | No crear usuarios humanos ni asignar AdministratorAccess; recibir roles existentes explícitos |
| `terraform/grafana-iam.tf` | Referencia conceptual | IRSA original no equivale a Pod Identity; se agrega módulo nuevo para controladores, sin políticas amplias por defecto |
| `terraform/frontend.tf`, `frontend/` | Excluidos | SPA energética/S3/CloudFront no son Backstage |
| `terraform/versions.tf` | Nuevo root | Sin bucket de estado de reference; ejemplo de backend independiente |
| `.terraform.lock.hcl` | Lock AWS conservado | AWS 6.64.0; TLS se elimina porque el nuevo EKS no crea un proveedor IRSA |
| `.github/workflows/ci.yml` | CI adaptada | Última ejecución del origen: success; se añaden pruebas simuladas y revisión de referencias |
| `cluster/values/*` | `reference/legacy/helm-values/` | Copia para diseñar GitOps; no instalación automática |
| `cluster/manifests/*` | Excluidos como manifiestos activos | Rutas de mediciones/facturación y namespace default no son el Golden Path |
| `scripts/bootstrap-cluster.sh` | Revisado, no trasladado como ejecutable | Instala por Helm/kubectl y lee secretos de reference; sustituir por bootstrap mínimo de Argo CD y GitOps |
| `scripts/smoke-deploy.sh` | Revisado, no trasladado como ejecutable | Ejecuta apply/destroy automáticos y restaura datos energéticos; incompatible con esta fase |
| `scripts/shutdown-current.sh` | Excluido | Operación destructiva y acoplada al entorno anterior |
| `scripts/backup-database.sh`, `restore-database.sh` | Excluidos | Dumps y esquema de reference no forman parte de Backstage ni del piloto |
| `scripts/verify.sh` | Reemplazado por validación local | Original consulta clúster, endpoints y AWS; nuevo script solo valida código y mocks |
| `experiments/`, `database/`, `grafana/`, `archive/` | No incorporados | Escenarios de energía, esquema y dashboards de negocio anteriores |
| `inventory/SHA256SUMS.txt` | Reemplazado por procedencia JSON | Los hashes originales no deben presentarse como validación del código adaptado |

## Hallazgos que afectan el nuevo proyecto

- El writer RDS original declara `publicly_accessible = true`; GoldenPath declara `false` y usa subredes de datos aisladas.
- El EKS original permite el endpoint público desde `0.0.0.0/0`; GoldenPath exige CIDRs restringidos o endpoint privado.
- El API Gateway original no exige autorización. El módulo adaptado usa IAM como estado seguro provisional: **no habilita por sí solo el login de navegador de Backstage**.
- Los SG de nodos no aíslan bases por namespace. Falta decidir Security Groups for Pods y políticas de red antes de afirmar ese aislamiento.
- El Istio original usa inyección de sidecars; la presentación propone ambient. Los valores copiados no implementan ambient.
- El origen lee credenciales desde Secrets Manager hacia Terraform. La base adaptada usa contraseña administrada de RDS y solo expone el ARN; falta integrar External Secrets con Backstage.
- Los tamaños/versiones probados en reference no acreditan capacidad ni compatibilidad de la nueva plataforma. Se requieren selección y validación propias.
