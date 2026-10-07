# CI y entrega GitOps

## CI de implementación

`ci.yml` tiene cuatro trabajos sin acceso AWS:

1. Terraform fmt/init/validate, siete planes con proveedor simulado, bootstrap-state y control de referencias/credenciales evidentes.
2. Siete pruebas de la política de solicitudes, Helm lint/render y ejecución real de function-patch-and-transform para los dos tamaños. Los objetos se validan con los esquemas fijados del proveedor AWS.
3. Pruebas unitarias del servicio y PostgreSQL real en Docker: TLS verificado, SELECT 1, fallo y recuperación.
4. Instalación inmutable, TypeScript, build de Backstage, backend local y dry-run real del formulario; se comprueba rechazo de altas arbitrarias de catálogo.

Acciones de checkout/setup fijadas por SHA. Terraform, dependencias de aplicaciones y charts tienen versiones/locks. Los workflows no incluyen AWS credentials, OIDC, apply, destroy ni despliegue a Kubernetes.

## Política de solicitudes

`goldenpath-policy.yml` usa pull_request_target exclusivamente para ramas `goldenpath/`. Ejecuta el código del **SHA base confiable** y lee los dos archivos propuestos como datos mediante GitHub API. Nunca hace checkout ni ejecuta código del PR. Publica el check `goldenpath-policy` en su SHA exacto; Backstage valida origen, rama, base y resultado antes de fusionar con condición de SHA.

El workflow debe estar en `main` antes de usar el formulario por primera vez. Los administradores del repositorio siguen siendo una frontera de confianza: pueden modificar políticas, workflows y la configuración de plataforma. Se recomienda proteger main y limitar administración antes de ampliar la demo a más equipos.

## Entrega

La entrega de aplicaciones usa Argo CD. Los repositorios generados incluyen CI de Node.js y manifiestos que utilizan la imagen genérica `service-v0:v1`. Este es el contrato del servicio v0: cambiar su código todavía no construye/publica automáticamente una imagen propia. Para v1 de la plataforma se puede agregar construcción por servicio con OIDC y actualización de digest en GitOps.

La publicación inicial de las dos imágenes (Backstage y v0) está implementada en `scripts/publish-images.sh`, con plataforma linux/amd64 y autorización explícita. ECR tiene tags inmutables: no volver a publicar un tag existente; actualizar versiones/valores para siguientes releases. El bootstrap y apply son scripts operativos manuales, bloqueados por defecto. No se ejecutaron durante esta preparación.

Las referencias del CI original de reference se mantienen en `reference/legacy`, fuera de `.github/workflows`. No se copiaron permisos ni automatizaciones de despliegue de ese entorno.
