# Guion del video · GoldenPath

## Historia

“Necesito un microservicio con PostgreSQL. Antes pedía repositorio, namespace, base y credenciales. Ahora completo cuatro campos y la plataforma conserva el gobierno en Git.”

## Secuencia de grabación

1. Mostrar GoldenPath, login GitHub y equipo piloto. Explicar el resultado esperado en una frase.
2. Abrir Crear → microservicio PostgreSQL. Completar nombre único, equipo piloto, tamaño pequeña y descripción. Iniciar cronómetro visible.
3. Mostrar tareas de Backstage: contrato validado, repositorio, PR de infraestructura, política y fusión. Abrir el PR y los dos archivos permitidos.
4. Mostrar Argo CD: Application de infraestructura y del servicio. Explicar que los cambios declarados se reconcilian desde Git.
5. Mostrar RDS Ready y Deployment disponible en la vista Kubernetes. Mostrar únicamente nombres de Secrets, nunca sus valores.
6. Usar port-forward del Service y abrir su respuesta: `database: connected`. Esto ejecuta SELECT 1 con TLS verificado.
7. Mostrar catálogo con dueño, repositorio y sistema. Cerrar el cronómetro y declarar el tiempo real.
8. Demostrar un rechazo de contrato en PR/dry-run (tamaño o centro de costo inválido). Explicar retención de bases y cierre de costos.

## Preparación de toma

Ensayar OAuth usando la URL real de API Gateway con `/dev`. Preparar una vista limpia de Backstage, GitHub y Argo CD. La UI de Argo CD solo se abre por port-forward autorizado; no hacerla pública. Usar un nombre nuevo por toma para evitar colisiones. Las esperas de RDS se pueden acelerar en edición, rotulando claramente tiempo transcurrido; no simular éxito ni atribuir el resultado local a AWS.

La prueba local permite grabar un adelanto del formulario y explicar la arquitectura, pero el video de extremo a extremo requiere desplegar y verificar la plataforma. No se ha realizado ese despliegue.

Relacionar cada toma con la [matriz de evidencias de aceptación](EVIDENCIAS-ACEPTACION.md); registrar tiempos reales y estado del entorno.
