# Diagnóstico y alcance de la TVP

GoldenPath aborda una fricción concreta: solicitar por ticket la infraestructura de un servicio y mantener cambios manuales sin reconciliación. La TVP entrega un servicio de desarrollo con PostgreSQL mediante cuatro campos y contratos predefinidos.

## Fuente y calidad de la evidencia

La [presentación del equipo](https://rubiod1.github.io/payments-network-platform-engineering/) describe una organización de pagos con desarrollo interno y operación de infraestructura tercerizada. Los tiempos, volumen de APIs y puntuaciones son reportes/estimaciones del equipo; no provienen de una extracción de tickets realizada por este repositorio. Al ser público, no se incluyen datos empresariales identificables ni expedientes internos.

Antes de defender una mejora cuantitativa, incorporar una entrevista o muestra de tickets anonimizada con fecha, rol entrevistado, tamaño de muestra y método de cálculo. No convertir la animación de la presentación en una medición.

## Priorización reportada

Impacto = frecuencia + equipos afectados + tiempo perdido + riesgo operacional; cada eje se califica entre 1 y 5. Es una priorización cualitativa, no una estimación monetaria.

| Fricción | Frecuencia | Equipos | Tiempo | Riesgo | Total /20 | Esfuerzo /5 | Decisión |
|---|---:|---:|---:|---:|---:|---:|---|
| F1 · Aprovisionamiento por ticket | 5 | 5 | 5 | 3 | 18 | 3 | Primero |
| F3 · Drift y recuperación manual | 3 | 5 | 3 | 5 | 16 | 2 | Junto con F1 |
| F4 · Descubrimiento y propiedad de APIs | 4 | 5 | 3 | 3 | 15 | 4 | Semilla de catálogo; integración posterior |
| F2 · Pipelines repetidos sin abstracción | 3 | 4 | 3 | 2 | 12 | 4 | Segunda etapa |
| F5 · Apagado desigual y sin medición | 2 | 2 | 1 | 2 | 7 | 3 | Gobierno/costos; automatización futura |

F1 y F3 comparten solución: declarar recursos en Git y reconciliarlos. La complejidad del dominio de negocio permanece en el equipo; la plataforma absorbe elecciones repetidas de infraestructura, credenciales y registro.

## Contrato del primer Golden Path

- Usuario: un desarrollador autorizado del equipo piloto.
- Entrada: nombre del servicio, equipo, tamaño pequeña/mediana y descripción.
- Ambiente: desarrollo; un motor PostgreSQL.
- Salida: repo privado, manifiestos, RDS por servicio, Secret, catálogo Component y dos Applications (infraestructura/servicio).
- Namespace: compartido por el equipo y preparado en bootstrap.
- Precondiciones: plataforma sana, imágenes publicadas, OAuth/PAT configurados y permisos AWS delegados.

Quedan fuera producción, multiclúster, nuevos motores, autoservicio IAM, lógica de negocio, construcción automática de imágenes propias, monetización, GPU y AI Gateway. La [evolución de APIs](APIS-Y-EVOLUCION.md) se diseña sin convertirla en varios Golden Paths para esta entrega.

## Antes y después que se deben comprobar

| Aspecto | Situación reportada | Resultado buscado |
|---|---|---|
| Espera por recurso | 3–4 días hábiles por ticket, estimación del equipo | Medir tiempo formulario → servicio Ready; objetivo inicial menor de 15 min |
| Operación por solicitud | Ticket y entrega manual de conexión | Cero intervenciones manuales después de enviar un contrato válido |
| Gobierno | Revisión y decisiones caso a caso | Contrato validado en Git y admisión |
| Drift | Detección/corrección manual | Reconciliar un cambio controlado de un campo administrado |
| Propiedad | Búsqueda manual | Dueño, repositorio y estado visibles en el portal |

## Medición del piloto

Registrar T0 al enviar el formulario; T1 al fusionar el PR; T2 con RDS Ready; T3 cuando `/readyz` y `/` devuelvan 200. Duración de autoservicio = T3 − T0. Registrar intentos fallidos, pasos manuales, tamaño y commit. Separar el tiempo de bootstrap del tiempo por solicitud y explicar cualquier corte del video.

Con un solo ensayo no se puede afirmar un percentil ni una reducción general de productividad. Comparar tiempos hábiles del proceso anterior con tiempos transcurridos del nuevo de forma explícita. El ahorro estimado no equivale a dinero liberado hasta conocer frecuencia y costo de trabajo reales.

Pendientes humanos: confirmar dueño operativo, equipo piloto, fuente de tiempos y permiso de divulgar evidencia anonimizada. Ver [matriz de aceptación](EVIDENCIAS-ACEPTACION.md).
