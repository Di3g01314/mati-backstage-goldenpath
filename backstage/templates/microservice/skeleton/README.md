# ${{ values.name }}

${{ values.description }}

Equipo: `${{ values.owner }}`. Ambiente: desarrollo. La infraestructura es administrada por la plataforma; Argo CD sincroniza `deploy/`.

- `npm ci && npm test`: pruebas sin AWS.
- `docker build -t mi-servicio:v2 .`: imagen propia.
- Publica esa imagen en un ECR accesible al clúster y cambia `deploy/deployment.yaml` por commit. El build/publicación del equipo permanece fuera de la TVP.
- `/healthz`: proceso vivo. `/readyz`: SELECT 1 a PostgreSQL. Las credenciales provienen del Secret creado por Crossplane.

Si el scaffolder falla después de crear el repo, conserva el enlace del task y el PR: no borres recursos para reintentar. La plataforma puede retomar/validar el PR existente antes de repetir la solicitud.
