# APIs y evolución de la plataforma

Hay tres superficies distintas: la API de Backstage, el contrato Kubernetes `PostgreSQLInstance` y la API HTTP del servicio v0. API Gateway protege la entrada del portal; no significa que ya exista un producto completo de gestión de APIs de negocio.

## Contratos existentes

| Superficie | Consumidor | Contrato y gobierno |
|---|---|---|
| Plantilla de Backstage | Desarrollador autorizado | Cuatro campos; equipo/identidad validados por acciones del backend |
| `PostgreSQLInstance` | Plantilla y Argo CD | `platform.goldenpath.io/v1alpha1`, namespace piloto, solo `spec.size`, owner/cost-center obligatorios |
| Registro `service.json` | ApplicationSets | `name`, `namespace`, `team`, `repoURL` exactos; política del PR impide cambios arbitrarios |
| Servicio v0 | Verificación interna | HTTP GET y PostgreSQL TLS; [OpenAPI documental](apis/service-v0.openapi.yaml) |

El OpenAPI documenta el servidor actual; **no está servido por un endpoint ni registrado todavía como entidad API en Backstage**. Es un artefacto de documentación, no evidencia de integración del catálogo de APIs.

### API del servicio v0

| Ruta | Respuesta normal | Fallo |
|---|---|---|
| `GET /healthz` | 200, `status: alive`, nombre y versión; no consulta la BD | El proceso puede estar vivo aunque RDS no responda |
| `GET /readyz` | 200 después de SELECT 1 | 503, `database: unavailable`, sin errores privados |
| `GET /` | 200 con `database: connected` | 503 si falla PostgreSQL |
| Otra ruta GET | — | 404 `not_found` |
| Método distinto de GET | — | 405 `method_not_allowed` |

No hay autenticación de aplicación ni rate limit implementado en el servicio v0; su exposición es interna y depende de los controles de red. Para una API de negocio deben diseñarse autorización, contrato, límites y tratamiento de datos propios. No trasladar el PAT de Backstage al servicio.

## Auditoría de capacidades actuales de la organización

La presentación reporta un gestor existente y más de 300 APIs, sin evidencia exportada en este repo. El runtime se considera habilitador; descubrimiento, propiedad y analítica se describen como fricciones. Validar esa hipótesis con inventario anonimizado de APIs/owners/versiones y una muestra de consultas de consumo antes de defender resultados.

Diseño propuesto de integración: conservar el gateway existente; exportar especificaciones OpenAPI y metadatos; validar dueño y ciclo de vida en PR; registrar entidades API en Backstage. La URL/método de exportación dependen del gestor real y están por confirmar. No se han conectado sistemas corporativos.

## Servicios del portal por etapa

| Servicio | Estado de esta entrega | Próximo paso verificable |
|---|---|---|
| Catálogo de servicios con dueño | Component generado en el Golden Path | Capturar registro real tras desplegar |
| Catálogo API/OpenAPI | Contrato documental; integración pendiente | Añadir entidad API, relación providesApis y extensión de documentación; comprobar navegación |
| Documentación viva | Propuesta | Validar contratos en CI y fijar versión visible |
| Onboarding de consumidores | Fuera de TVP | Definir autoridad OAuth y permisos antes de automatizar credenciales |
| Cuotas y consumo | Fuera de TVP | Definir consumidor/plan y fuente de métricas; no confundir throttling del portal con cuotas por consumidor |
| Versionado/deprecación | Diseño | Calendario, dueño y aviso a consumidores |
| Monetización | Excluida del piloto interno | Revisar solo si existe un modelo real de cobro |

## Platform 2.0: decisión y condición de reapertura

| Tendencia | Decisión | Justificación técnica y financiera | Cuándo revisarla |
|---|---|---|---|
| FinOps embebido | Mínimo en código: owner, centro de costo y dos tamaños | Permite atribución y limita capacidad. No calcula factura, no hay AWS Budgets ni dashboard creados. Ver [costos](COSTOS.md). | Cuando haya gasto observado o más equipos que necesiten atribución |
| Green IT | Automatización pospuesta | No hay scheduler ni etiqueta horaria activa. Retener RDS y EKS limita ahorros; medir horas ociosas antes de atribuir ahorro energético. | Cuando exista línea base y política de parada/retención aprobada |
| AI Gateway | Excluido de esta TVP | No hay caso de consumo LLM validado en este alcance. Agregaría gobierno de datos, operación y precio variable por consumo. | Caso aprobado, dueño, demanda y presupuesto medidos |
| Cargas IA/GPU | Excluidas | Cambian capacidad y operación sin resolver el ticket PostgreSQL. No comparar un costo GPU mensual con presupuesto de una ventana corta. | Carga propia de entrenamiento/inferencia con SLA y costo estimados |

La exclusión temporal cumple el objetivo de evaluar alternativas; no obliga a implementar todas las tendencias. Conservar la TVP acotada y registrar nuevas decisiones en [ADRs](adr/README.md).
