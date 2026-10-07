# Primer despliegue: preparación y operación

**No se ha desplegado en AWS.** La implementación y las pruebas previas están listas; las operaciones de esta página se ejecutan solo después de autorizar el despliegue y revisar el plan vigente.

## Datos externos pendientes

- Confirmar cuenta/región final, administrador EKS, presupuesto y ventana de uso. Se consultó disponibilidad en us-east-1 para EKS 1.35 y PostgreSQL 16.15.
- Configurar acceso al endpoint privado EKS desde VPN/host con acceso VPC, o establecer CIDRs administrativos explícitos para endpoint público. No usar 0.0.0.0/0.
- Crear una OAuth App GitHub con homepage igual a `portal_url` y callback `<portal_url>/api/auth/github/handler/frame`, conservando `/dev`.
- Preparar PAT para la cuenta personal con capacidad de crear repositorios privados, leer/escribir código, publicar PR y fusionarlos. El scaffolder debe poder incorporar el archivo CI a los repositorios generados (en PAT clásico: `repo` y `workflow`). Mantenerlo dedicado a la demo, con vencimiento y rotación. Verificar permisos según el tipo de token elegido.
- Crear un secreto de sesión aleatorio (mínimo 32 bytes). Los valores nunca se incluyen en Git ni en archivos de variables de Terraform.

## 1. Backend dedicado

`terraform/bootstrap-state` prepara un bucket S3 cifrado, versionado, privado, TLS-only y protegido contra borrado. Su estado inicial es local: conservarlo de forma segura y migrarlo al mismo bucket con una clave separada al terminar. No se debe borrar ese estado.

Tras autorización, revisar/aplicar el plan de ese root con `account_id`, región y `deployment_enabled=true`. Copiar `terraform/backend.tf.example` a `terraform/backend.tf`, sustituir el bucket real y ejecutar `terraform init`. El backend usa bloqueo S3 `use_lockfile`; los permisos del operador deben permitir el estado y su lock.

## 2. Plan de cimientos

Copiar `terraform/terraform.tfvars.example` a un archivo ignorado y completar cuenta, administrador, snapshot final y acceso EKS. Mantener `deployment_enabled=false` en el archivo; el script habilita el gate únicamente para generar el plan explícito.

```bash
export EXPECTED_AWS_ACCOUNT=CUENTA_DESTINO
./scripts/plan-aws.sh "$PWD/terraform/environment.tfvars"
```

El script compara STS con la cuenta esperada, inicializa el backend si está configurado y guarda `.generated/aws.tfplan` y JSON privados. Revisar recursos, costos, versiones y permisos. No reutilizar el plan preliminar local después de configurar el backend: generar uno nuevo. Un plan exitoso no prueba permisos de Create, cuotas ni el arranque del clúster.

## 3. Operaciones autorizadas

Estos scripts cambian AWS y están bloqueados salvo que `GOLDENPATH_ALLOW_DEPLOY=1` y la cuenta coincida. **No ejecutarlos durante la preparación.**

```bash
export GOLDENPATH_ALLOW_DEPLOY=1
./scripts/apply-foundation.sh "$PWD/.generated/aws.tfplan"
./scripts/publish-images.sh
PYTHON_BIN="$PWD/.venv/bin/python" ./scripts/bootstrap-platform.sh
```

Entre apply y bootstrap: consultar `terraform output portal_url`, completar OAuth y escribir el valor del secreto GitHub creado por Terraform en Secrets Manager. JSON requerido:

```json
{
  "GITHUB_TOKEN": "VALOR_FUERA_DE_GIT",
  "GITHUB_CLIENT_ID": "VALOR_FUERA_DE_GIT",
  "GITHUB_CLIENT_SECRET": "VALOR_FUERA_DE_GIT",
  "AUTH_SESSION_SECRET": "VALOR_ALEATORIO_FUERA_DE_GIT"
}
```

Usar consola o carga de archivo privado, no valores literales en el historial de shell. `seed-argocd-credentials.py` lee ese secreto en memoria y prepara la credencial inicial del Git privado; ESO mantiene su ciclo de vida posteriormente. La contraseña RDS la administra AWS.

Bootstrap usa kubeconfig propio en `.generated/aws-kubeconfig`, instala Argo CD y configura el resto mediante GitOps. Requiere que este cambio esté fusionado en `main`. El endpoint privado debe ser accesible desde la máquina que ejecuta bootstrap. Si falla a mitad, inspeccionar Applications/CRDs y reintentar; no borrar bases para resolver una reconciliación.

## 4. Verificación real

```bash
./scripts/verify-deployment.sh
```

Revisar Applications Healthy/Synced, Provider/Function Healthy, ESO listo y portal HTTPS/login. Crear un servicio desde Backstage, seguir el PR y comprobar RDS Ready, Secret presente y Deployment disponible. Probar SELECT 1 mediante port-forward del Service. No mostrar tokens, passwords ni dumps de Secrets en el video.

Comprobar adicionalmente aislamiento de red, Pod Identity, acceso efectivo del proveedor RDS, certificados y callbacks OAuth a través de `/dev`. Medir el tiempo real desde el formulario a disponibilidad; la meta de unos 10 minutos no está validada.

## Cierre y costos

EKS, dos workers, NAT, NLB, WAF, RDS, logs, secretos y almacenamiento generan cargos. Calcular presupuesto con precios actuales antes del apply y fijar una ventana de apagado.

No existe destroy automático. Las bases están protegidas y las del piloto se retienen: inventariar y respaldar, autorizar su eliminación, ajustar temporalmente políticas/protecciones, verificar borrado en AWS y solo entonces desmontar controladores y cimientos. Borrar EKS primero puede dejar RDS huérfanas. Conservar estado, snapshots y logs según la retención acordada.
