# Monitoring

## Netdata

Netdata is a highly performant monitoring and troubleshooting tool for Linux. My choice is motivated by the fact that it's opensource and self-hosted, with deep integration with Kubernetes and deep observability. This one will be used only locally.

It is deployed under `core/netdata/`.

> **Note:** The free / open-source version of Netdata is limited to a maximum of 5 nodes.

## VictoriaMetrics

VictoriaMetrics is deployed for cluster-wide metrics collection, long-term storage, alerting and visualization.

It is installed using the official **VictoriaMetrics Operator** together with the `victoria-metrics-k8s-stack` Helm chart, under `operators/serverside/victoria-metrics/`.

The stack includes:

- **Grafana** for dashboards (`grafana.menia.cc`)
- **vmagent** for scraping and remote write (`vmagent.menia.cc`)
- **Alertmanager** (`alertmanager.menia.cc`)
- **VMSingle** as the time-series database (`vm.menia.cc`)

All these services are exposed via HTTPRoutes on the LAN (they are not publicly accessible).

This setup was chosen as a high-performance, Prometheus-compatible replacement for the classic Prometheus + Alertmanager + Grafana stack, with much better storage efficiency.
