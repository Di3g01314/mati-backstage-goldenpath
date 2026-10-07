# Video de la TVP

Guion previsto; ninguna evidencia se presenta como ya ejecutada.

| Escena | Acción | Evidencia a obtener |
|---|---|---|
| 1. Problema y solución | Mostrar el formulario y sus cuatro campos | Servicio, equipo, tamaño y descripción; ambiente dev fijo |
| 2. Autoservicio | Enviar solicitud con cronómetro | Repo del servicio y PR GitOps generados |
| 3. Entrega declarativa | Mostrar checks y las dos Applications | Infraestructura y servicio con fuentes/permisos separados |
| 4. AWS real | Ver recurso compuesto y estado RDS | Base privada y recurso Ready; sin mostrar contraseñas |
| 5. Resultado | Abrir servicio y catálogo | SELECT 1 exitoso, owner y repo correctos |
| 6. Autonomía | Cambiar imagen por commit | Argo sincroniza la nueva versión |
| 7. Reconciliación | Alterar un atributo reversible de la RDS de prueba | Crossplane restaura el valor declarado |
| 8. Guardrails | Solicitar tamaño inválido o quitar centro de costo | Rechazo claro antes de crear recurso |

Registrar duración real, versiones, commit y condiciones de la prueba. Si se edita el video para recortar la espera, mostrar el tiempo transcurrido real. El cronómetro empieza con los cimientos ya disponibles: aprovisionar EKS no forma parte del tiempo de cada solicitud.

Para la grabación final: datos ficticios, cuenta de laboratorio, ventanas legibles y recorrido ensayado. Capturar errores útiles y recuperación cuando formen parte del criterio. No ejecutar cambios de drift en recursos ajenos a la PoC.
