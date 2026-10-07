# Costos de la PoC

Actualización: **7 de octubre de 2026**, us-east-1, USD, On-Demand, sin impuestos, descuentos ni créditos. La tarifa RDS `db.t3.micro` se consultó en AWS el 7 de octubre; las demás tarifas conservan la consulta del 6 de octubre. Esta es una base de estimación, no una factura ni un presupuesto aprobado. La infraestructura ya está activa; consultar el [registro del despliegue](DESPLIEGUE-AWS.md) para su estado operativo.

## Configuración y subtotal conocido

Escenario: un EKS en soporte estándar, dos workers t3.large Linux, una RDS del portal y una RDS piloto pequeñas `db.t3.micro`, un NAT zonal, una IPv4 pública del NAT y un NLB interno. El escenario contempla dos bases; actualmente solo existe la RDS de Backstage y la base piloto aún no se ha creado. El ajuste de RDS a `db.t3.micro` responde a falta de capacidad de `db.t4g.micro` con `gp3` durante el despliegue. Los importes EC2/RDS se consultaron en la API pública de precios de AWS; se conserva el [registro de tarifas y filtros](costos/precios-consultados.json).

| Concepto | Cantidad | USD por unidad/h | USD/h del escenario | Fuente |
|---|---:|---:|---:|---|
| EKS, soporte estándar | 1 | 0.1000 | 0.1000 | [Precios EKS](https://aws.amazon.com/eks/pricing/) |
| EC2 t3.large Linux | 2 | 0.0832 | 0.1664 | [Tarifas consultadas](costos/precios-consultados.json) |
| RDS PostgreSQL db.t3.micro Single-AZ | 2 | 0.0180 | 0.0360 | [Tarifas consultadas](costos/precios-consultados.json) |
| NAT Gateway zonal | 1 | 0.0450 | 0.0450 | [Precios VPC](https://aws.amazon.com/vpc/pricing/) |
| IPv4 pública del NAT | 1 | 0.0050 | 0.0050 | [Precios IPv4](https://aws.amazon.com/vpc/pricing/) |
| NLB interno, cargo fijo | 1 | 0.0225 | 0.0225 | [Precios NLB](https://aws.amazon.com/elasticloadbalancing/pricing/) |
| **Subtotal parcial** | | | **0.3749** | Cómputo y cargos fijos de red anteriores |

| Horas de existencia de esos recursos | Subtotal parcial USD |
|---:|---:|
| 8 | 3.00 |
| 24 | 9.00 |
| 160 | 59.98 |
| 730, mes de referencia | 273.68 |

Estos subtotales excluyen los conceptos siguientes. Por sí solos ya superan USD 50 para 160 horas. No son una estimación integral de la demo ni su límite de gasto.

## Completar antes de aprobar presupuesto

| Concepto adicional | Dato necesario |
|---|---|
| WAF | Una Web ACL y una regla: referencia USD 5 + USD 1 por mes, prorrateados; solicitudes aparte según [AWS WAF](https://aws.amazon.com/waf/pricing/) |
| API Gateway REST | Solicitudes y salida de datos; [tarifas regionales](https://aws.amazon.com/api-gateway/pricing/) |
| NLCU y transferencia | Conexiones/bytes, NAT GB, tráfico entre AZ y salida Internet; no están incluidos en el cargo fijo NLB |
| EBS de workers | Capacidad y tipo efectivos del node group; no inferir el costo del disco a partir de la tarifa EC2 |
| RDS gp3 y snapshots | 20 GiB por base en el contrato actual; retención y backups fuera de lo incluido; [RDS PostgreSQL](https://aws.amazon.com/rds/postgresql/pricing/) |
| KMS, Secrets Manager y CloudWatch | Claves, secretos, llamadas, ingesta y retención |
| ECR y S3 de estado | Imágenes, almacenamiento, versiones y solicitudes |
| CPU burst | Posibles cargos de créditos en las familias burstable según configuración/uso |
| Más servicios o tamaño mediano | Cada RDS adicional agrega instancia, almacenamiento y respaldos; consultar la tarifa de la clase mediana efectiva |
| Operación humana | Preparación, diagnóstico, mantenimiento y cierre; no es cero aunque el cambio sea YAML |

Modelo: sumar `tarifa × unidades × horas` de cada recurso, cargos de almacenamiento/retención y consumo variable. Introducir el escenario completo en [AWS Pricing Calculator](https://calculator.aws/) y conservar el enlace/exportación saneada. Cotizar una ventana de demo y un escenario de olvido encendido; no comparar tamaños distintos sin recalcular.

## Reproducir la consulta EC2/RDS

Con permiso de lectura de precios y AWS CLI, el endpoint Pricing se consulta en us-east-1. Las tarifas corresponden a los filtros, no a una factura de la cuenta.

```bash
aws pricing get-products --region us-east-1 --service-code AmazonEC2 \
  --filters Type=TERM_MATCH,Field=instanceType,Value=t3.large \
  Type=TERM_MATCH,Field=location,Value='US East (N. Virginia)' \
  Type=TERM_MATCH,Field=operatingSystem,Value=Linux \
  Type=TERM_MATCH,Field=tenancy,Value=Shared \
  Type=TERM_MATCH,Field=preInstalledSw,Value=NA \
  Type=TERM_MATCH,Field=capacitystatus,Value=Used

aws pricing get-products --region us-east-1 --service-code AmazonRDS \
  --filters Type=TERM_MATCH,Field=instanceType,Value=db.t3.micro \
  Type=TERM_MATCH,Field=location,Value='US East (N. Virginia)' \
  Type=TERM_MATCH,Field=databaseEngine,Value=PostgreSQL \
  Type=TERM_MATCH,Field=deploymentOption,Value=Single-AZ
```

## Control y cierre

La infraestructura ya genera cargos. Mantener asignados responsable, techo de gasto y fecha de retirada; estos deben revisarse también antes de cualquier ampliación. Las etiquetas owner/cost-center ayudan a atribuir recursos, pero el código no crea alarmas de AWS Budgets ni detiene recursos automáticamente. Configurar esos controles como una operación futura autorizada; no presentarlos como activos.

La facturación sigue el tiempo de existencia/uso de recursos, no las horas que la persona trabaja en ellos. Detener el portal deja EKS, NAT, NLB y bases generando costos. Las bases piloto están retenidas: el ahorro depende de una baja coordinada, no de ejecutar destroy a ciegas. Seguir [operación y cierre](OPERACION.md).
