# Guía del equipo

Esta guía permite revisar y probar GoldenPath sin desplegar recursos AWS. Para operar un entorno real, seguir [preparación del despliegue](PREPARACION-DESPLIEGUE.md).

## 1. Obtener la implementación

```bash
git clone https://github.com/Di3g01314/mati-backstage-goldenpath.git
cd mati-backstage-goldenpath
git switch feat/goldenpath-platform
```

Mientras el [PR #1](https://github.com/Di3g01314/mati-backstage-goldenpath/pull/1) esté abierto, la implementación completa está en esa rama. Después de fusionarlo, utilizar `main`. Para clones anteriores a la limpieza del historial, lo más sencillo es clonar de nuevo en otra carpeta; conservar primero cualquier trabajo local.

Leer [alcance](DIAGNOSTICO-Y-ALCANCE.md), [arquitectura](ARQUITECTURA.md) y [límites de validación](VALIDACION.md). El permiso de leer el repositorio público no implica permiso de escritura, GitHub OAuth ni acceso AWS.

## 2. Preparar herramientas

| Herramienta | Versión usada | Necesaria para |
|---|---|---|
| Node.js | 24.21.0 | Portal y servicio |
| Yarn | 4.13.0, incluido en el repo | Dependencias de Backstage |
| Python | 3.10 o posterior | Validadores; entorno virtual propio |
| Terraform | 1.16.2 | Formato, validate y pruebas mock |
| Docker | Motor activo | PostgreSQL de prueba y funciones Crossplane |
| Helm | 4.3.0 | Render de charts |
| Crossplane CLI | 2.5.0 | Render local con motor 2.4.2 |
| OpenSSL, curl, Bash, compilador C/C++ y make | Disponibles en PATH | Certificados locales, harness y módulos nativos de Node |

Instalar las herramientas del sistema antes de comenzar; `npm ci` y Yarn descargan dependencias. La primera instalación del portal puede tardar varios minutos. No es necesario configurar AWS CLI ni un token GitHub para estas pruebas.

```bash
python3 -m venv .venv
.venv/bin/pip install -r scripts/requirements.txt
cd backstage
node .yarn/releases/yarn-4.13.0.cjs install --immutable
node .yarn/releases/yarn-4.13.0.cjs start
```

Abrir `http://localhost:3000`; el backend usa `http://localhost:7007`. Ingresar como invitado y explorar el catálogo y la plantilla Microservicio con PostgreSQL. El modo local utiliza SQLite en memoria, identidad `user:development/guest` y destinos ficticios. **El botón final de creación no ejecuta un Golden Path remoto válido en este modo:** usar el dry-run para comprobar la generación de archivos.

Detener el portal con Ctrl+C antes del siguiente paso: el harness de prueba necesita el puerto 7007 libre.

## 3. Verificar el formulario y los contratos

Desde la raíz del repositorio:

```bash
PYTHON_BIN="$PWD/.venv/bin/python" ./scripts/test-backstage.sh
.venv/bin/python -m unittest discover -s tests -v
```

El harness inicia el backend, prueba que un usuario no pueda registrar plantillas arbitrarias y ejecuta las acciones de contexto/render sin publicar repositorios. El resultado está en `.generated/scaffolder/`: `service/` contiene el repositorio generado; `gitops/` contiene exactamente `database.yaml` y `service.json`. Estos archivos son temporales y no se suben a Git.

## 4. Validar según el cambio

| Cambio | Comando desde la raíz |
|---|---|
| Terraform | `./scripts/validate.sh` |
| Política de solicitudes | `.venv/bin/python -m unittest discover -s tests -v` |
| Charts/XRD/Composition | `.venv/bin/python scripts/validate-platform.py` |
| Servicio | `(cd services/service-v0 && npm ci && npm test)` |
| Conexión real PostgreSQL/TLS | `python3 scripts/test-service-integration.py` |
| Portal | `(cd backstage && node .yarn/releases/yarn-4.13.0.cjs tsc && node .yarn/releases/yarn-4.13.0.cjs build:backend)` |

`TERRAFORM_BIN` y `CROSSPLANE_BIN` permiten indicar una ruta a los binarios. El conjunto completo se describe en [CI/CD](CI-CD.md). Ninguno de estos comandos crea infraestructura AWS. Los tests de integración crean y retiran sus propios contenedores locales; no usar comandos de limpieza global de Docker.

## 5. Contribuir

Crear una rama desde la implementación vigente, hacer un cambio acotado y abrir un PR con problema, resultado y validación. Antes de la fusión del PR #1, coordinar cambios sobre su rama para no crear trabajos sobre el `main` incompleto. Después, basar las ramas en `main`.

Actualizar documentación y ADR cuando cambien interfaces o decisiones. No editar los lockfiles manualmente. Revisar `git diff --check` y ejecutar el validador apropiado. Si aparece un secreto en un diff, retirarlo y rotarlo antes de compartirlo; no adjuntar logs que lo contengan.

## Responsabilidades por confirmar

| Rol | Responsabilidad | Persona |
|---|---|---|
| Responsable de plataforma | Arquitectura, PR y cambios del control plane | Por asignar por el equipo |
| Operador de la demo | Cuenta/región, bootstrap y cierre | Por asignar por el equipo |
| Dueño del piloto | Caso de uso, aceptación y datos de diagnóstico | Por asignar por el equipo |
| Responsable de evidencia | Tiempos, capturas y video | Por asignar por el equipo |

Reportar fallos con commit, comando, entorno y error saneado. Para secretos, permisos o costos, dirigirse al operador; para el contrato de cuatro campos, al responsable de plataforma. No se han asignado roles humanos por defecto.
