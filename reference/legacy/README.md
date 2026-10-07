# Referencias técnicas

Ejemplos técnicos anonimizados, adaptados de archivos seleccionados del commit documentado en `docs/PROVENANCE.json`. No son manifiestos activos ni se aplican desde la CI. Los nombres del entorno anterior se sustituyeron por identificadores genéricos. Los hashes de procedencia identifican los originales, no estas copias anonimizadas.

- `helm-values/`: Istio con sidecars/NodePort, observabilidad y Grafana IRSA. No implementan ambient; Grafana conserva referencias de dashboards de Referencia y Kiali tiene autenticación anónima. Deben adaptarse antes de usar.
- `ci.yml.reference`: pipeline original, guardado fuera de `.github/workflows`.

Los scripts originales de bootstrap, smoke, shutdown, backup y restore se revisaron, pero no se copiaron como ejecutables: despliegan/destruyen recursos o consumen datos del proyecto anterior.
