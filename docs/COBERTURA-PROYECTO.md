# Cobertura del Proyecto Integrador #1 y rúbrica

Revisión: 6 de octubre de 2026. Fuentes: guía `2026-20-MATI-PLAT-PROYECTO.pdf` (2 páginas), capturas de rúbrica suministradas por el equipo, [presentación vigente](https://rubiod1.github.io/payments-network-platform-engineering/) y código de GoldenPath. Los adjuntos se usan como requisitos y evidencia de contexto, no como autorización para desplegar.

**Conclusión:** las cuatro secciones están representadas en la presentación. La entrega completa todavía no está demostrada: falta ejecutar y registrar el Golden Path real y reconciliar varias afirmaciones de la presentación con la implementación. No corresponde afirmar nivel 4/4 en la PoC con un plan de Terraform o pruebas aisladas. Esta revisión no asigna una nota del profesor.

## Matriz de cobertura

| Criterio | Evidencia existente | Estado | Qué falta para sostener nivel 4 |
|---|---|---|---|
| Diagnóstico socio-técnico y TVP | Presentación sección I: F1–F5, calificación por frecuencia/equipos/tiempo/riesgo, esfuerzo, priorización F1+F3 y límites explícitos. Template de cuatro campos y un ambiente. | Bien cubierto como análisis | Respaldar las estimaciones con entrevistas/tickets anonimizados o indicar quién las reportó y cuándo. No presentar 3–4 días ni 10 min como medición formal. Identificar equipo piloto y dueño operativo. |
| Arquitectura lógica | Figura 2 con cinco capas; código Terraform, charts y documentación de arquitectura. | Cubierto con discrepancias | Alinear componentes efectivos, observabilidad y fronteras de confianza. Separar arquitectura objetivo de PoC. |
| Vista física | Figura 3: hub/spokes objetivo y un EKS en la PoC, separación por namespaces. | Cubierta como diseño | No atribuir aislamiento por cuenta/clúster a la PoC. Explicitar falla compartida y costo de la simplificación. |
| Vista de red y Zero-Trust | Figura 4, IAM Pod Identity, SGs, NetworkPolicy, ambient, WAF. | Parcialmente alineada | Corregir endpoints privados, autenticación del borde, TLS y alcance de SG por namespace; verificar tráfico y denegaciones reales en EKS. |
| Vista de eventos | Figura 5, metadatos, watches y reconciliación; ApplicationSets y Composition. | Cubierta como diseño | La implementación consulta Git periódicamente: no hay webhook de GitHub expuesto/configurado. Notifications no está configurado para un canal. No presentar esos eventos como comprobados. |
| Ciclo de vida de plataforma | Figura 6 y CI, GitOps, versiones fijadas, runbook. | Parcialmente alineado | Kind validó esquemas/admisión, no creó RDS ni probó drift. No hay entorno staging/prod desplegado ni promoción por tags activa. Dos revisores/protecciones de rama deben comprobarse si se declaran. |
| Auditoría de APIs | Sección III: gestor anonimizado, evaluación por capacidad y decisión de conservar runtime actual. | Cubierta como análisis declarado | Añadir evidencia mínima por capacidad y mecanismo concreto de exportación/OpenAPI. Las cifras 300+ y tiempos son aportes del equipo, no hallazgos técnicos verificados aquí. |
| Servicios de gestión de APIs | Tabla y figura 7: catálogo, docs, onboarding, cuotas, analítica y versiones por fase. | Cubierto como diseño | El catálogo implementado registra Component, System, Group y User; falta la entidad API/OpenAPI prometida como semilla en PoC. El API Gateway del portal no implementa por sí solo gestión de APIs de negocio. |
| Platform 2.0 | Matriz técnica/financiera de FinOps, Green IT, AI Gateway y cargas IA, con condiciones de reapertura. | Cubierto con correcciones financieras | Etiquetas y tamaños limitan costo pero no apagan recursos ni prueban ahorro. Falta etiqueta/operación de horario declarada. Revisar presupuesto real y fuentes de precios; no sostener “más de diez veces el presupuesto” con comparación mensual vs ventana de uso. |
| PoC y evidencia empírica | Repositorio, Terraform, Backstage, servicio, GitOps y pruebas locales descritas en VALIDACION. | Implementada para ensayo; E2E pendiente | Login real → formulario → repo/PR/check/merge → Applications → RDS Ready → Secret → SELECT 1 → catálogo, sin intervención manual durante cada solicitud. Grabar y medir. |

## Diferencias concretas que deben corregirse en la presentación

1. **Red privada:** el código usa NAT para salida; no crea los VPC endpoints STS/RDS/Secrets Manager/ECR/Logs que muestra la figura 4. GitHub y los registros externos requieren salida. Presentar endpoints como evolución o implementarlos tras evaluar costo.
2. **TLS y OAuth:** NLB es TCP:80 y el gateway recibe HTTP:80/NodePort30080. HTTPS termina en API Gateway; login GitHub se verifica en Backstage. No existe authorizer OIDC de API Gateway ni TLS:443 interno. No rotular esta ruta como TLS extremo a extremo.
3. **Aislamiento de bases:** piloto tiene SG para pods etiquetados; la base de Backstage permite el SG de workers, no un SG exclusivo de su namespace. NetworkPolicy/ambient del piloto no equivalen a mTLS para todos los namespaces del clúster.
4. **Costo:** la implementación usa 2 × t3.large, no 2 × t3.medium. El presupuesto de USD 50 no está validado para este stack. Incorporar WAF, API Gateway, almacenamiento, IPs, secretos, logs y transferencia. No usar el total de la lámina como cotización.
5. **Cierre:** las RDS se protegen y retienen. `terraform destroy` entre sesiones no borra automáticamente las bases creadas por Crossplane y no es un procedimiento seguro de apagado. Seguir el runbook de retención y cierre.
6. **Bootstrap:** el chart inicial se instala con Helm. Las anotaciones sync-wave entre Applications no garantizan su orden inicial; la convergencia depende de reconciliación/reintentos. La presentación afirma app-of-apps con raíz reconciliada: corregir esa afirmación o implementar esa raíz antes de declararla.
7. **CI y drift:** hay render real de Crossplane, esquemas, admisión local y Scaffolder dry-run. No se ejecutó creación de una RDS ni drift en un hub efímero. La corrección de drift de campos administrados tampoco garantiza deshacer cualquier cambio externo.
8. **Namespace:** se prepara un namespace por equipo durante bootstrap. El formulario registra el servicio y su base dentro del namespace existente; no crea uno distinto por servicio.
9. **Imágenes:** el servicio v0 usa imagen genérica. Construcción automática de imágenes por servicio y actualización de tag están fuera de TVP, consistente con los límites de la presentación. No contarlo como fallo de cobertura.
10. **Reproducibilidad:** los secretos OAuth/PAT y permisos iniciales son prerrequisitos operativos. El objetivo medible es cero intervención por solicitud después de bootstrap, no una cuenta vacía sin configuración inicial.

## Cierre de evidencia para la sustentación

| Evidencia | Cómo obtenerla | Situación actual |
|---|---|---|
| Diagnóstico antes | Uno o dos tickets/entrevistas anonimizados con tiempos y fuente | Lo aporta el equipo; no fabricar datos |
| Camino completo después | Video continuo o cortes declarados; cronómetro desde envío hasta SELECT 1 | Pendiente de despliegue autorizado |
| Gobierno | PR de dos archivos, check de política y rechazo de costo/tamaño inválidos | Contratos y admisión local probados; capturar en entorno final |
| Autonomía del servicio | Commit de manifiesto con imagen válida y Argo sincronizando | Pendiente en EKS |
| Drift F3 | Cambio controlado de retención de backup de la RDS piloto, lectura antes/después y restauración por Crossplane | Pendiente; requiere cambio AWS explícitamente autorizado |
| Catálogo | Dueño/repositorio/estado de la base y entidad API si se conserva como semilla prometida | Component preparado; estado AWS/API pendiente |
| Costos | Estimación vigente por recurso y ventana, más plan de cierre | Pendiente de presupuesto final |

## Límite de alcance

La guía exige construir funcionalmente **el primer Golden Path**. Pide diseñar/evaluar servicios de APIs y tendencias 2.0, no implementar monetización, AI Gateway, GPU, Green IT y multiclúster completos. Incluirlos todos ahora inflaría la TVP y debilitaría el criterio que pide evitar sobreingeniería.

La presentación lista cinco integrantes y una empresa con desarrollo interno/AWS. El vínculo laboral de al menos un integrante, el permiso de usar la información y la elección del piloto los confirma el equipo; no se deducen de este repositorio.
