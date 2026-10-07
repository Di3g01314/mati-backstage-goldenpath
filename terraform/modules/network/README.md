# Red dedicada

Origen: `terraform/network.tf` del commit de referencia registrado en [procedencia](../../../docs/PROVENANCE.json). Revisar [decisiones y limitaciones](../../../docs/ARQUITECTURA.md) antes de desplegar.

Entradas documentadas en [variables.tf](variables.tf), recursos en [main.tf](main.tf) y contrato de salida en [outputs.tf](outputs.tf). Este módulo no configura credenciales ni backend: los recibe del root.

La validación de este repositorio es estática y con mocks; aún no se ha probado el despliegue de esta adaptación en AWS.
