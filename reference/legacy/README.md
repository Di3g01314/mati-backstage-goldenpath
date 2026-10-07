# Referencia de reference

Archivos seleccionados copiados del commit documentado en `docs/PROVENANCE.json`. No son manifiestos activos ni se aplican desde la CI. Conservar el contenido permite revisar qué se heredó.

- `helm-values/`: Istio con sidecars/NodePort, observabilidad y Grafana IRSA. No implementan ambient; Grafana conserva referencias de dashboards de reference y Kiali tiene autenticación anónima. Deben adaptarse antes de usar.
- `ci.yml.reference`: pipeline original, guardado fuera de `.github/workflows`.

Los scripts originales de bootstrap, smoke, shutdown, backup y restore se revisaron, pero no se copiaron como ejecutables: despliegan/destruyen recursos o consumen datos del proyecto anterior.
