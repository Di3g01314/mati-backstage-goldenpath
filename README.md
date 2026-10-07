# GoldenPath · Arquitectura de Plataformas

Base de infraestructura para la TVP de autoservicio de ARTI-4219, derivada de los recursos reutilizables de reference. Objetivo del proyecto: un desarrollador solicita un microservicio con PostgreSQL en Backstage; GitHub, Argo CD y Crossplane lo materializan en AWS.

**Estado: preparación y validación sin AWS. No se ha desplegado esta plataforma.** El repositorio contiene los cimientos modulares y CI; el Golden Path todavía está pendiente. La configuración bloquea el despliegue por defecto (`deployment_enabled = false`). No existe un workflow de apply ni de destroy.

## Reutilización

| Módulo | Alcance preparado |
|---|---|
| `network` | VPC dedicada, NAT, subredes públicas, privadas de aplicación y aisladas de datos |
| `eks` | Clúster, nodos, roles, clave KMS propia, accesos explícitos y add-ons parametrizados |
| `rds-postgres` | Una RDS privada para Backstage, cifrada, respaldada y con contraseña administrada por AWS |
| `ecr` | Repositorios nuevos para Backstage y servicio v0, tags inmutables y análisis de imágenes |
| `portal-edge` | API Gateway HTTP → VPC Link → NLB interno → NodePort; módulo opcional, desactivado |
| `pod-identity` | Rol y asociación por namespace/service account; falta definir políticas de los controladores |

La RDS del piloto será propiedad de **Crossplane**. Terraform prepara únicamente la base del portal y los cimientos. El módulo Pod Identity está disponible para integración, aún no instanciado en el root.

## Estructura

```text
terraform/
  modules/                 # seis módulos con variables y outputs
  tests/                   # contratos con proveedor AWS simulado
  main.tf                  # composición del entorno de desarrollo
  terraform.tfvars.example # parámetros pendientes; despliegue deshabilitado
  backend.tf.example       # backend nuevo e independiente, aún no configurado
.github/workflows/ci.yml    # formato, validación y pruebas sin AWS
scripts/validate.sh         # mismo proceso local y en GitHub Actions
reference/legacy/          # valores Helm y CI originales, solo referencia
platform/                  # contratos y trabajo pendiente de GitOps
services/service-v0/       # contrato de la aplicación futura
catalog/                   # contrato del futuro catálogo
docs/                     # inventario, decisiones, pendientes y demo
```

## Validación local

Requiere Terraform 1.16.2, Python 3 y Bash. Descargar proveedores requiere Internet; no requiere una cuenta AWS.

```bash
./scripts/validate.sh
```

El script ejecuta `init -backend=false`, `validate` y pruebas con `mock_provider "aws"` y `command = plan`. No ejecuta un plan contra AWS, no aplica recursos y no usa kubectl. El resultado no demuestra que una versión de EKS/RDS esté disponible ni que IAM permita desplegar.

## Documentación de trabajo

- [Inventario y decisiones de reutilización](docs/INVENTARIO-REUTILIZACION.md)
- [Procedencia exacta y hashes](docs/PROVENANCE.json)
- [Arquitectura y límites de esta base](docs/ARQUITECTURA.md)
- [CI/CD revisado y siguiente implementación](docs/CI-CD.md)
- [Pendientes antes de desplegar](docs/PREPARACION-DESPLIEGUE.md)
- [Guion y criterios para el video](docs/DEMO.md)
- [Presentación de referencia](https://rubiod1.github.io/payments-network-platform-engineering/)

El repositorio se mantiene privado, al igual que su origen. No se copiaron estados, contraseñas, claves, dumps, recursos retenidos ni credenciales de reference. Los valores Helm de referencia no son la configuración activa de GoldenPath.
