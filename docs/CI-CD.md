# CI/CD

## Lo que existe en el origen

reference tiene un workflow `CI - validacion sin AWS` (PR y ejecución manual). El último commit revisado pasó. Hace formato/validación Terraform, sintaxis shell, JSON de dashboards y checksums. Sus despliegues son scripts manuales, no un workflow CD. La instrucción original `bash -n scripts/*.sh experiments/*.sh` no garantiza revisar cada archivo: aquí se usa un bucle por archivo.

Se conserva el YAML original en `reference/legacy/ci.yml.reference`; GitHub Actions no lo ejecuta desde allí.

## Lo que queda activo aquí

Un workflow CI en push a main, PR y ejecución manual:

1. Checkout con persistencia de credenciales deshabilitada.
2. Terraform 1.16.2 y proveedor AWS fijado por lockfile.
3. `fmt -check`, `init -backend=false -lockfile=readonly`, `validate`.
4. Pruebas con proveedor AWS simulado: aislamiento de subredes, RDS privada y protegida, ECR inmutable, gateway autenticado, EKS privado y bloqueo de despliegue.
5. Validación independiente de Pod Identity, sintaxis de cada script y revisión básica de credenciales/referencias heredadas.

Permisos del workflow: únicamente `contents: read`. No hay AWS secrets, token OIDC, backend remoto, apply, destroy ni bootstrap. Las pruebas ejercitan el código con datos simulados; no validan las autorizaciones reales ni disponibilidad regional.

Las acciones están fijadas al commit correspondiente a los tags verificados del origen. La revisión de credenciales es una comprobación básica por patrones, no una auditoría exhaustiva de secretos.

## CD pendiente (no configurado)

- Cimientos: workflow separado de ejecución manual, rol AWS vía GitHub OIDC acotado a repo/ref/environment y backend exclusivo; revisión del plan y autorización antes del primer apply.
- Bootstrap: instalación inicial de Argo CD desde un ejecutor con acceso al endpoint privado de EKS; después, app-of-apps.
- Plataforma/equipos: Argo CD sincroniza GitOps. El usuario no entrega credenciales AWS a las plantillas.
- Servicio v0: build, prueba de conexión y publicación en ECR. La imagen genérica inicial sí hace parte del arranque; automatizar builds de todos los servicios queda para la siguiente fase.
- PR del Golden Path: checks de políticas y merge automático limitado al contrato estándar, sin convertir los permisos del scaffolder en administración general de GitHub.

No se ha creado un workflow CD vacío o con capacidad latente de desplegar. Se agregará al implementar y autorizar esa fase.
