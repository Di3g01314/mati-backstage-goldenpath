# Vista 1 · Ubicación física

La PoC usa una cuenta, una región y un único EKS. La separación entre gestión y aplicaciones se implementa por namespaces y permisos; comparten nodos y dominio de falla.

```mermaid
flowchart TB
  Github["GitHub · plataforma y repositorios de servicios"]
  subgraph AWS["AWS · us-east-1 · cuenta de la demo"]
    EKSAPI["Control plane EKS administrado por AWS"]
    ECR["ECR · imágenes Backstage y servicio v0"]
    SM["Secrets Manager · integración y credencial del portal"]
    subgraph VPC["VPC 10.60.0.0/16 · tres AZ"]
      Public["Subredes públicas · un NAT Gateway"]
      subgraph Private["Subredes privadas de aplicación"]
        Nodes["Grupo de nodos · 2 t3.large deseados"]
        NLB["NLB interno"]
        subgraph Cluster["Namespaces sobre los mismos workers"]
          Control["backstage · argocd · crossplane-system"]
          Support["external-secrets · kyverno · istio-system · kube-system"]
          Pilot["equipo-piloto · servicios y Secrets de conexión"]
        end
      end
      subgraph Data["Subredes de datos aisladas · sin ruta de salida"]
        PortalDB["RDS Backstage · Terraform"]
        PilotDB["RDS por servicio · Crossplane"]
      end
    end
  end
  Github --> Control
  EKSAPI --- Nodes
  Nodes --- Cluster
  ECR --> Nodes
  SM --> Control
  NLB --> Support
  Control --> PortalDB
  Pilot --> PilotDB
  Private --> Public
```

| Zona | CIDR declarado | Función |
|---|---|---|
| Pública | `10.60.0.0/24`, `10.60.1.0/24`, `10.60.2.0/24` | Ruta a Internet Gateway; NAT en una AZ |
| Aplicación | `10.60.16.0/20`, `10.60.32.0/20`, `10.60.48.0/20` | Workers y NLB interno; salida por NAT |
| Datos | `10.60.64.0/24`, `10.60.65.0/24`, `10.60.66.0/24` | Subnet groups RDS sin ruta a NAT/Internet Gateway |

Los subnet groups abarcan tres AZ, pero ambas clases de base están configuradas Single-AZ. El grupo EKS tiene deseado 2, mínimo 1 y máximo 3; esos límites no instalan un autoscaler. No se garantiza un worker en cada AZ. La disponibilidad y capacidad reales requieren ensayo.

**Fuentes del código:** [root Terraform](../../terraform/main.tf), [red](../../terraform/modules/network/main.tf), [EKS](../../terraform/modules/eks/main.tf), [bootstrap](../../platform/charts/bootstrap/templates/applications.yaml).

La evolución a hub y spokes en cuentas distintas se justifica cuando aislamiento, disponibilidad o número de equipos superen esta PoC. Implica roles entre cuentas, conectividad privada y más clústeres; no se representa como un ahorro gratuito. Ver [ADR-002](../adr/002-UN-EKS-Y-NAMESPACE-POR-EQUIPO.md).
