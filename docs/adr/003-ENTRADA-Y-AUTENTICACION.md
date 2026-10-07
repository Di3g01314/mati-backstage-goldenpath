# ADR-003 · URL HTTPS de API Gateway y autenticación en Backstage

Fecha: 2026-10-06. Estado: **adoptada en la implementación; validación operativa AWS pendiente**.

## Contexto

El equipo eligió la URL administrada de API Gateway y no dispone de un dominio propio para la demo.

## Decisión

Usar API Gateway REST regional con WAF, VPC Link, NLB interno e Istio. Backstage autentica mediante GitHub y controla acceso a APIs; las rutas de assets/login deben funcionar antes de autenticarse.

## Alternativas consideradas

Un dominio con ALB/ACM cambia la solución elegida y exige DNS/certificado. Agregar un authorizer al borde requiere diseñar compatibilidad con sesiones y callbacks. Cifrar el tramo interno es una mejora separada.

## Consecuencias y límites

TLS termina en API Gateway y el transporte privado usa HTTP. El prefijo /dev debe mantenerse en baseUrl y callbacks. WAF de rate limit no sustituye autorización. La salida actual usa NAT, sin endpoints privados.

## Cuándo revisar

Antes de tratar datos sensibles en producción, exigir TLS interno o incorporar un proveedor corporativo de identidad.

## Trazabilidad

- [main.tf](../../terraform/modules/portal-edge/main.tf)
- [app-config.production.yaml](../../backstage/app-config.production.yaml)

[Volver al índice](README.md)
