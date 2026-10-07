# Evidencias de aceptación

Esta matriz conecta requisitos con verificaciones. Los resultados locales están descritos en [VALIDACION](VALIDACION.md); la ejecución de GitHub Actions se consulta en el PR. **No hay evidencia E2E en AWS todavía.**

| ID | Criterio | Evidencia exigida | Estado |
|---|---|---|---|
| E01 | TVP responde a una fricción priorizada | Fuente anonimizada de tickets/entrevista y criterio de prioridad | Análisis del equipo documentado; muestra verificable pendiente |
| E02 | Cimientos consistentes | fmt/validate, tests mock y plan con cuenta/región/commit registrados privadamente | Local: 7 tests y plan 102 altas, 0 cambios/bajas |
| E03 | Formulario abstrae infraestructura | Dry-run de cuatro campos y revisión de los archivos generados | Local: 12 archivos; sin escrituras GitHub/AWS |
| E04 | Solo se admiten solicitudes estándar | Caso válido y negativos de owner/costo/tamaño/namespace/archivos | Política: 7 tests; admisión local ensayada |
| E05 | Base y servicio se materializan | Task → repo/PR/check/merge → dos Applications → RDS Ready → Secret → Deployment | Pendiente AWS |
| E06 | Credenciales automáticas y TLS | SELECT 1 con certificado verificado; no entrega manual por solicitud | Docker: caída/recuperación probada; RDS real pendiente |
| E07 | Autoservicio completo | Cronómetro T0–T3 y conteo de intervenciones fuera del formulario | Pendiente; menos de 15 min es objetivo |
| E08 | Catálogo con propiedad y estado | Component visible con owner/repo/estado real | Plantilla preparada; captura del entorno final pendiente |
| E09 | Autonomía para actualizar servicio | Commit con imagen válida → Argo Synced → versión observada | Pendiente; construcción de imagen propia fuera de TVP |
| E10 | Corrección de drift F3 | Campo administrado cambiado autorizadamente → restauración automática → antes/después | Pendiente AWS; no ejecutar durante preparación |
| E11 | Aislamiento y permisos | Matriz de conexiones permitidas/denegadas y acceso limitado a APIs | Configurado; tráfico efectivo y Pod Identity pendientes EKS |
| E12 | APIs y evolución | Auditoría, contrato OpenAPI, fases y decisiones técnicas/financieras | Documentado; entidad API del catálogo pendiente |
| E13 | Cierre controlado | Inventario final, retenciones, costos residuales y responsables | Runbook preparado; ejecución pendiente |

## Ficha para cada ejecución

Copiar esta ficha en una evidencia nueva cuando realmente se ejecute:

```text
ID de criterio:
Fecha y zona horaria:
Commit y versión de imágenes:
Entorno (local / kind / AWS):
Responsable:
Precondiciones:
Acción o comando:
Resultado esperado:
Resultado observado:
Duración y pasos manuales:
Enlace a CI, captura o minuto del video:
Limitaciones / fallo y seguimiento:
```

Una captura sin commit/entorno no prueba reproducibilidad. En un video editado, rotular los saltos de tiempo. Registrar los fallos junto con el éxito final; no ocultar intervenciones que contradigan la afirmación de autoservicio.

## Ensayo de drift futuro

Elegir solo una RDS desechable del piloto y un campo administrado, por ejemplo retención de respaldos. Tras autorización, registrar valor deseado, cambiarlo de manera controlada, observar el ciclo de Crossplane y comprobar que AWS vuelve al valor declarado. Registrar latencia y condiciones Ready/Synced. No alterar contraseñas, cifrado, subredes ni borrar datos para hacer una demostración. El éxito con un campo no prueba reversión de cualquier cambio ni restauración ante pérdida de datos.

## Publicación de evidencia

Publicar únicamente salidas saneadas, capturas y enlaces accesibles al equipo. No publicar tfstate, plan binario/JSON completo, kubeconfig, tokens, secretos o identificadores corporativos. `.generated/` es material local de trabajo, no una carpeta para subir al repositorio. Enlazar esta matriz desde el [guion del video](DEMO.md) para que cada toma tenga un criterio concreto.
