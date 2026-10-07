# Registro del despliegue en AWS

**Fecha del registro: 7 de octubre de 2026, hora de Bogotá. Estado: infraestructura aplicada; portal pendiente de credenciales GitHub.** Este documento registra lo observado durante el primer despliegue de GoldenPath en `us-east-1`. La existencia de infraestructura e imágenes no demuestra todavía que el portal ni el Golden Path completo funcionen en AWS.

Después del apply, `terraform plan -detailed-exitcode` terminó con código 0 y **No changes**: los recursos de Terraform coinciden con la configuración. Esta comprobación no cubre la salud de los workloads Kubernetes.

La [guía de preparación y operación](PREPARACION-DESPLIEGUE.md) describe la secuencia prevista. Las [validaciones previas](VALIDACION.md) y las [evidencias de aceptación](EVIDENCIAS-ACEPTACION.md) conservan su alcance: las pruebas locales y el plan inicial no sustituyen la validación del entorno desplegado.

## Estado de los componentes

| Componente | Estado observado | Siguiente comprobación |
|---|---|---|
| Backend Terraform en S3 | Aplicado; estado migrado al backend remoto. | Mantener el estado y su bloqueo para los siguientes planes y operaciones. |
| VPC | Creada por Terraform. | Comprobar conectividad efectiva entre workloads, RDS y servicios de AWS. |
| Entrada API Gateway y NLB | Creados. | Validar la ruta completa hasta Backstage por la URL HTTPS de API Gateway. |
| EKS | Clúster activo; dos workers `Ready` y add-ons operativos. | Mantener la salud y comprobar la capacidad con los workloads del piloto. |
| Imágenes ECR | Backstage y servicio v0 publicados como `v1`, arquitectura `linux/amd64`. | Comprobar descarga y arranque de ambas imágenes en EKS. |
| RDS de Backstage | Disponible con PostgreSQL 16.15 y `db.t3.micro`, cifrada y sin acceso público. El primer intento `db.t4g.micro` falló por falta de capacidad. | Consulta `SELECT 1` con TLS verificado desde EKS aprobada; migraciones del backend pendientes. |
| Argo CD | Instalado. Crossplane, ESO e Istio saludables; proveedores RDS/family y función instalados y saludables. | Completar credenciales GitHub y comprobar la sincronización final de todas las Applications. |
| Secretos RDS y Pod Identity | ClusterSecretStore válido; ExternalSecret RDS sincronizado mediante el rol de ESO. | Validar el resto de identidades durante el Golden Path. |
| Credenciales GitHub | Existe el secreto de destino `goldenpath-dev/github-app`, todavía sin versión cargada. | Identificar el secreto indicado por el usuario por nombre o ARN y región, y completar la configuración requerida. |
| Backstage y Golden Path | Pendientes de validación integrada. | Completar la matriz de pruebas de este documento antes de declarar la PoC funcional. |

El ajuste de clase RDS respondió a un error real de capacidad y AWS confirmó la instancia alternativa disponible. Ambas clases micro ofrecen 2 vCPU y 1 GiB. La consulta de precios de AWS de esta ejecución dio USD 0,018/h para `db.t3.micro` frente a USD 0,016/h para `db.t4g.micro`: USD 0,002/h adicionales por base, sin incluir almacenamiento. Un Job temporal en el namespace `backstage`, usando la imagen del servicio v0 y el Secret sincronizado, ejecutó `SELECT 1` sobre la base `backstage` con `rejectUnauthorized=true` y el certificado raíz RDS. Resultado: `ok=true`, `tls=true`, `certificateVerified=true`. El Job no modificó datos. Las migraciones y el arranque de Backstage siguen pendientes.

## Admisión del contrato en EKS

Una solicitud `PostgreSQLInstance` válida fue aceptada mediante `kubectl apply --dry-run=server`. La misma solicitud con un propietario distinto de `piloto` fue rechazada por la regla `require-owner-cost-size`. No se persistieron recursos ni se creó una base para esta prueba. Esto verifica la admisión del contrato; el aprovisionamiento de RDS por Crossplane y el aislamiento de tráfico del piloto quedan pendientes del recorrido completo.

## Imágenes publicadas

Los identificadores siguientes fueron confirmados en ECR. Son metadatos de artefactos; no contienen credenciales ni identificadores de cuenta.

| Repositorio | Tag | Arquitectura | Digest |
|---|---|---|---|
| `goldenpath-dev/backstage` | `v1` | `linux/amd64` | `sha256:d76c06e1a1d269b960cd2937c5f9c49f78cd8a72ed5b358e2cbca025875a150e` |
| `goldenpath-dev/service-v0` | `v1` | `linux/amd64` | `sha256:a79c321fc91daa69e9761202635e5e25419ccdcd6d7ca6e0ce6486677d2d354b` |

Antes de publicar se verificó la arquitectura y se ejecutaron ambos runtimes AMD64: Node.js, la dependencia PostgreSQL del servicio y una consulta `SELECT 1` en SQLite para comprobar la dependencia nativa de Backstage. Esta última prueba valida la imagen, no la conexión con RDS. Los repositorios ECR usan tags inmutables; una modificación posterior de la imagen debe publicarse con un tag nuevo y actualizar la configuración de despliegue.

## Validaciones pendientes en AWS

| Prueba | Estado | Evidencia necesaria para darla por terminada |
|---|---|---|
| Nodos y add-ons EKS | Verificado | Dos nodos `Ready`; VPC CNI, CoreDNS, kube-proxy y Pod Identity Agent operativos. |
| GitOps | Por validar | Argo CD disponible y Applications esperadas `Synced` / `Healthy`, sin errores de permisos o CRDs. |
| RDS real de Backstage | Conectividad verificada; backend pendiente | Instancia disponible; `SELECT 1` y TLS verificado desde un Job de EKS. Faltan migraciones y arranque del backend. |
| Portal por API Gateway | Por validar | Interfaz y APIs accesibles en HTTPS usando la ruta de etapa configurada. |
| Login GitHub | Por validar | Inicio de sesión, callback OAuth y pertenencia al equipo resueltos correctamente. |
| Scaffolder completo | Por validar | Formulario de cuatro campos; repositorio creado; PR validado e integrado; entidad de catálogo registrada. |
| RDS real del piloto | Por validar | Crossplane crea y reconcilia la instancia del servicio con el tamaño solicitado; conexión disponible en el namespace correcto. |
| Servicio y `SELECT 1` | Por validar | Deployment disponible; consulta contra la RDS del piloto mediante TLS verificado; respuesta de disponibilidad correcta. |
| Aislamiento y permisos | Por validar | Identidades de pods, controles de red y restricciones del equipo comprobados en el entorno real. |
| Corrección de drift | Por validar | Cambio controlado, detección y reconciliación observables, sin exponer datos sensibles. |
| Tiempo de autoservicio | Por medir | Tiempo desde envío del formulario hasta servicio y base disponibles; registrar el resultado real. |

La meta de unos diez minutos sigue siendo un objetivo. Solo podrá presentarse como resultado cuando el recorrido completo esté medido. El video y la aceptación final se preparan con evidencias de esas ejecuciones reales.

## Cómo continuar y registrar resultados

1. Conservar el backend remoto y los inputs locales del despliegue; el plan posterior al apply confirmó ausencia de diferencias.
2. Identificar la credencial GitHub indicada por el usuario sin publicar sus valores; completar OAuth y secreto de sesión para la URL definitiva del portal.
3. Terminar bootstrap y reconciliación de Argo CD, verificar identidades, secretos y arranque de Backstage.
4. Ejecutar la [verificación del despliegue](../scripts/verify-deployment.sh) y el recorrido de autoservicio. Registrar fecha, commit y resultado de cada prueba.
5. Actualizar esta tabla y las [evidencias de aceptación](EVIDENCIAS-ACEPTACION.md) con resultados observados. Conservar los fallos y su resolución para explicar las decisiones operativas.

Los planes, estados, kubeconfig, identificadores reales de cuenta, archivos de credenciales y logs sensibles permanecen fuera del repositorio. Las capturas y el video deben mostrar estados y resultados sin tokens, contraseñas ni contenido de Secrets. Los recursos ya creados generan cargos aunque el portal aún no esté validado; el cierre debe seguir la [guía de operación](OPERACION.md) y respetar la retención de las bases.
