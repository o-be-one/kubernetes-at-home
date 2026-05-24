# Operators

This repository deploys several Kubernetes operators under the `operators/` directory.

They are managed by two ApplicationSets (see `core/argocd/appset-operators.yaml`):

- `operators` (normal)
- `operators-serverside` (uses `ServerSideApply=true`)

## Current operators

| Operator | Location | Notes |
| --- | --- | --- |
| CloudNativePG (CNPG) | `operators/serverside/cnpg-system/` | Postgres operator |
| MariaDB Operator | `operators/mariadb-operator/` | MariaDB operator + Helm chart |
| VictoriaMetrics | `operators/serverside/victoria-metrics/` | Metrics stack |

Each operator directory follows the same pattern as apps and core components (kustomization + optional secret generators).

## References

**CloudNativePG (CNPG)**
- [CloudNativePG Official Documentation](https://cloudnative-pg.io/docs/)

**MariaDB Operator**
- [MariaDB Operator Documentation](https://github.com/mariadb-operator/mariadb-operator)

**VictoriaMetrics**
- [VictoriaMetrics Operator](https://docs.victoriametrics.com/operator/)
- [victoria-metrics-k8s-stack](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack)
