# Entrada del portal

API Gateway REST regional con HTTPS administrado por AWS, stage dev, WAF de límite por IP y throttling. VPC Link conecta un NLB interno al NodePort 30080 del gateway Istio. Las rutas raíz y proxy admiten login OAuth y assets; Backstage controla autenticación de sus APIs.

Sin dominio propio. TLS termina en API Gateway; transporte privado HTTP. Ver `docs/ARQUITECTURA.md` para límites y verificación pendiente de callbacks/rutas en AWS.
