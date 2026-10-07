# Operación, diagnóstico y cierre

Runbook para el operador del piloto. La infraestructura AWS está activa; el portal sigue pendiente de completar la configuración GitHub y validar su funcionamiento. Consultar el [registro de despliegue](DESPLIEGUE-AWS.md) para el estado vigente. La secuencia del primer arranque está en [PREPARACION-DESPLIEGUE](PREPARACION-DESPLIEGUE.md); esta guía explica cómo observar y recuperar el entorno.

## Acceso y primera comprobación

Requiere un operador autorizado, conectividad al endpoint EKS y el kubeconfig de GoldenPath generado por bootstrap. No usar el contexto Kubernetes personal por defecto.

```bash
export KUBECONFIG_GOLDENPATH="$PWD/.generated/aws-kubeconfig"
./scripts/verify-deployment.sh
kubectl --kubeconfig "$KUBECONFIG_GOLDENPATH" -n argocd get applications
kubectl --kubeconfig "$KUBECONFIG_GOLDENPATH" -n equipo-piloto get postgresqlinstances,pods,services
```

`verify-deployment.sh` comprueba control plane y estado de Applications; no crea un servicio ni prueba login o SELECT 1 por sí mismo. La evidencia completa está en [aceptación](EVIDENCIAS-ACEPTACION.md).

## Diagnóstico por síntoma

| Síntoma | Revisar primero | Recuperación controlada |
|---|---|---|
| Portal no carga | Stage `/dev`, URL del output, health de Backstage y gateway, targets NLB | Corregir configuración declarada; no publicar el NLB para sortear el fallo |
| OAuth rechaza el login | Callback exacto, secreto sincronizado y User del catálogo | Ajustar OAuth/identidad y comprobar pertenencia; no habilitar guest en producción |
| Task creó repo pero falla después | Task, PR, SHA y resultado del check | Resolver causa y revisar artefactos existentes antes de repetir; la creación no es transaccional |
| Check rechaza la solicitud | Dos archivos, namespace, owner/costo/tamaño y repo esperado | Corregir contrato o plantilla mediante PR; no fusionar omitiendo política |
| Application no sincroniza | Repo credentials, rama, AppProject y CRD requerido | Corregir Git/configuración; los reintentos ayudan durante bootstrap, pero no resuelven permisos inválidos |
| Proveedor no Healthy / XR no Ready | Condiciones, Pod Identity, SA, IAM, cuota y error AWS | Modificar rol/Composition por sus propietarios declarativos; no crear la RDS a mano con el mismo nombre |
| Pod en CreateContainerConfigError | Existencia/nombre del Secret de conexión | Revisar estado de la RDS/proveedor; no copiar contraseñas al manifiesto |
| ImagePullBackOff | Tag, repositorio ECR, permisos de nodos y arquitectura amd64 | Publicar una imagen válida autorizadamente o revertir al tag previo; no sobrescribir v1 |
| Readiness 503 / liveness 200 | Estado RDS, SG/SGP, DNS, NetworkPolicy y certificado | Diagnosticar conexión; no desactivar validación TLS para declarar éxito |
| Gastos después de retirar servicios | RDS retenidas, NAT, EKS, NLB, volúmenes y snapshots | Inventariar recursos y aplicar cierre explícito; borrar Kubernetes no implica borrar AWS |

Eventos y logs pueden contener datos operativos: revisarlos localmente y sanear antes de adjuntarlos a un issue público. Nunca ejecutar `kubectl get secret -o yaml` como captura de evidencia.

## Probar un servicio de forma interna

Sustituir `gp-piloto-demo` por el nombre generado. Requiere permiso de port-forward y un Deployment disponible.

```bash
kubectl --kubeconfig "$KUBECONFIG_GOLDENPATH" -n equipo-piloto port-forward service/gp-piloto-demo 8080:80
```

En otra terminal, consultar `curl -i http://localhost:8080/readyz` y `curl -i http://localhost:8080/`. Detener el túnel con Ctrl+C. Un port-forward prueba el servidor y su conexión a RDS, pero no demuestra que el ingreso normal ni las políticas de malla funcionen; comprobar esas rutas separadamente.

## Recuperación y responsables

El responsable de plataforma decide cambios de contrato/controladores; el operador gestiona IAM, conectividad y costos; el dueño del servicio valida su comportamiento. Las personas están por asignar en la [guía del equipo](GUIA-EQUIPO.md). Escalar con commit, hora, síntoma, recurso y acciones ya intentadas; nunca enviar credenciales.

Para rollback de manifiestos/imágenes y diferencias con restauración de datos, usar la [vista de ciclo de vida](vistas/04-CICLO-DE-VIDA.md). Una restauración de RDS requiere ensayar endpoint, Secret y reconexión; este repo no incluye una restauración automatizada comprobada.

## Cierre de la demo

Este procedimiento requiere autorización de la operación; no constituye un script de destroy automático.

1. Suspender nuevas solicitudes y coordinar GitOps para que no recree lo que se va a retirar. Registrar los recursos de cada servicio y sus propietarios.
2. Identificar qué datos deben conservarse y crear/verificar snapshots cuando corresponda; definir responsable y vencimiento de la retención.
3. Mientras EKS y Crossplane sigan disponibles, preparar el cambio explícito de políticas/protecciones necesario para dar de baja bases piloto. Revisar que la política IAM permita la operación acordada. Eliminar el XR bajo la configuración actual no elimina RDS.
4. Verificar en AWS la eliminación o retención acordada de cada base y reconciliar los objetos pendientes. No retirar controladores con recursos sin inventariar.
5. Preparar un plan revisado de retirada de cimientos. La RDS del portal tiene protección y snapshot final; EKS, NAT/NLB y demás recursos se retiran solo cuando sus dependencias estén resueltas.
6. Conservar estado/backend y los snapshots autorizados. Revisar recursos facturables restantes, credenciales OAuth/PAT y retención de secretos/logs/imágenes.

Registrar hora de cierre y evidencia de inventario. Cerrar la terminal o apagar los pods no detiene la facturación de EKS, NAT, NLB o RDS. Revisar [costos](COSTOS.md).
