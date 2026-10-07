# GoldenPath · Arquitectura de Plataformas

Plataforma de autoservicio para MATI: un desarrollador completa **nombre, equipo, tamaño y descripción** en Backstage y obtiene un repositorio privado, microservicio, PostgreSQL y catálogo, administrados mediante GitOps.

**Implementación preparada y validada antes del despliegue. No se ha desplegado en AWS.** Terraform tiene un bloqueo por defecto y los workflows no tienen credenciales AWS ni ejecutan despliegues. El plan real consultó AWS: **102 recursos nuevos, cero modificaciones y cero eliminaciones**. Eso no garantiza permisos de creación ni el funcionamiento de las integraciones en AWS; consulta [evidencias y límites](docs/VALIDACION.md).

## Qué incluye

- **Terraform:** seis módulos de infraestructura para GoldenPath; VPC independiente, EKS, RDS del portal, ECR, entrada HTTPS mediante API Gateway REST/WAF/NLB y roles Pod Identity. Backend S3 separado listo para bootstrap.
- **Backstage:** aplicación compilable, autenticación GitHub, catálogo, formulario de cuatro campos y acciones que validan identidad, crean el servicio y esperan la política del PR antes de fusionarlo.
- **GitOps:** Argo CD, proyectos con permisos separados, ApplicationSets, Crossplane v2, Composition de PostgreSQL con dos tamaños, External Secrets, Kyverno e Istio ambient.
- **Servicio v0:** Node.js/PostgreSQL, SELECT 1 con TLS verificado, disponibilidad dependiente de la base y recuperación comprobada.
- **CI:** Terraform, contratos de solicitudes, render de Helm/Crossplane, compilación de Backstage, Scaffolder real en dry-run y pruebas con PostgreSQL real en Docker.

La entrada pública del portal usa **la URL HTTPS de API Gateway**, sin dominio propio. OAuth se configura después de conocer esa URL. Argo CD y los servicios del piloto permanecen internos.

## Estructura

| Ruta | Contenido |
|---|---|
| `terraform/` | Entorno, módulos, pruebas y bootstrap del estado |
| `backstage/` | Portal, catálogo y plantilla del Golden Path |
| `platform/` | Charts GitOps, versiones y esquemas de proveedores |
| `gitops/tenants/` | Solicitudes de infraestructura y registros de servicios |
| `services/service-v0/` | Imagen genérica y pruebas de PostgreSQL |
| `scripts/` | Validaciones, plan y operaciones futuras con bloqueo explícito |
| `reference/legacy/` | Referencias técnicas anonimizadas; no se despliegan |

## Validación local

Requiere Terraform 1.16.2, Node 24.21.0, Python 3.10+, Helm 4.3.0, Crossplane CLI 2.5.0 y Docker. Las descargas requieren Internet; las pruebas de CI no requieren AWS.

```bash
./scripts/validate.sh
python3 -m venv .venv
.venv/bin/pip install -r scripts/requirements.txt
.venv/bin/python -m unittest discover -s tests -v
.venv/bin/python scripts/validate-platform.py
(cd services/service-v0 && npm ci && npm test)
python3 scripts/test-service-integration.py
(cd backstage && node .yarn/releases/yarn-4.13.0.cjs install --immutable && node .yarn/releases/yarn-4.13.0.cjs tsc && node .yarn/releases/yarn-4.13.0.cjs build:backend)
PYTHON_BIN="$PWD/.venv/bin/python" ./scripts/test-backstage.sh
```

Para explorar el portal localmente: `cd backstage && node .yarn/releases/yarn-4.13.0.cjs start`. El modo local usa SQLite, usuario invitado y destinos ficticios; permite probar el formulario sin publicar servicios.

## Documentación

- [Índice de documentación para el equipo](docs/README.md)
- [Guía de inicio y contribución](docs/GUIA-EQUIPO.md)
- [Cuatro vistas operativas](docs/vistas/README.md) y [decisiones de arquitectura](docs/adr/README.md)

- [Cobertura de la guía y rúbrica](docs/COBERTURA-PROYECTO.md)
- [Arquitectura y decisiones](docs/ARQUITECTURA.md)
- [Preparación y secuencia del primer despliegue](docs/PREPARACION-DESPLIEGUE.md)
- [CI y políticas GitOps](docs/CI-CD.md)
- [Validación realizada y límites](docs/VALIDACION.md)
- [Guion del video](docs/DEMO.md)
- [Inventario de reutilización](docs/INVENTARIO-REUTILIZACION.md) y [procedencia exacta](docs/PROVENANCE.json)
- [Presentación de contexto](https://rubiod1.github.io/payments-network-platform-engineering/)

Repositorio público de GoldenPath; los repositorios que crea el Golden Path para cada servicio se configuran privados. No contiene estados, contraseñas ni claves privadas. Los archivos PEM incluidos son certificados públicos de confianza de Amazon RDS.
