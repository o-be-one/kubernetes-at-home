# Monitoring

The cluster uses two complementary layers:

- **Beszel** — base monitoring and alerting for the cluster nodes themselves (lightweight, day-to-day host health).
- **VictoriaMetrics** — deeper observability (Prometheus-compatible scraping, long-term storage, Grafana, Alertmanager). It is better suited to rich metrics pipelines and is intended to monitor services beyond the cluster, not only the nodes.

## Beszel

[Beszel](https://beszel.dev/) is a lightweight, self-hosted monitoring hub with per-node agents. It provides the base monitoring and alerting layer for the Talos nodes (CPU, memory, disk, network).

It is deployed under `core/beszel/`:

- **Hub** — Deployment + Longhorn PVC, UI at `https://mon.menia.cc` (LAN-only HTTPRoute)
- **Agents** — DaemonSet (`hostNetwork`) on every node, including control-plane; agents connect to the hub over WebSocket

Secrets (`KEY` = hub public SSH key, `TOKEN` = universal registration token) live in `core/beszel/secret.enc.yaml` (SOPS). After rotating the token in the hub UI (`/settings/tokens`), update the secret and restart the DaemonSet.

Notes specific to this cluster:

- Agents use WebSocket only (`DISABLE_SSH=true`); they talk to the in-cluster hub Service, not the Gateway.
- Talos uses containerd, not Docker/Podman — container metrics from Beszel are not available (`DOCKER_HOST=""`).
- Namespace PSA stays `privileged` because agents need `hostNetwork` (required for host NIC stats). Containers themselves are non-root / least-privilege.

### Alerting

Beszel can send alerts when systems go down or cross thresholds (CPU, memory, disk, etc.). Notifications are configured in the hub UI (**Settings → Notifications**) as [Shoutrrr](https://containrrr.dev/shoutrrr/) URLs — one library, many backends (Pushover, Discord, Slack, Gotify, email, …).

On my cluster, alerts go through **Pushover**. Other channels are just another Shoutrrr URL away if needed. Per-system alerts are enabled from the systems table in the UI.

## VictoriaMetrics

VictoriaMetrics is the deep observability stack: cluster-wide metrics collection, long-term storage, alerting and visualization. Beyond node health, the goal is to scrape and monitor other services (applications, operators, exporters) with a Prometheus-compatible model.

It is installed using the official **VictoriaMetrics Operator** together with the `victoria-metrics-k8s-stack` Helm chart, under `operators/serverside/victoria-metrics/`.

The stack includes:

- **Grafana** for dashboards (`grafana.menia.cc`)
- **vmagent** for scraping and remote write (`vmagent.menia.cc`)
- **Alertmanager** (`alertmanager.menia.cc`)
- **VMSingle** as the time-series database (`vm.menia.cc`)

All these services are exposed via HTTPRoutes on the LAN (they are not publicly accessible).

This setup was chosen as a high-performance, Prometheus-compatible replacement for the classic Prometheus + Alertmanager + Grafana stack, with much better storage efficiency.

## Netdata (example only)

Netdata used to live under `core/` as a local troubleshooting UI. It was dropped as an active cluster component after a license change last year that limits the free / open-source edition to a maximum of **5 nodes**.

The manifests were moved to `examples/apps/netdata/` (not auto-deployed by the main ApplicationSets) and are kept only as a **reference / inspiration** if someone wants to experiment with that stack again.

## References

**Beszel**
- [Beszel Documentation](https://beszel.dev/)
- [Hub installation](https://beszel.dev/guide/hub-installation)
- [Agent installation](https://beszel.dev/guide/agent-installation)
- [Kubernetes / advanced deployment](https://beszel.dev/guide/advanced-deployment)
- [Notifications (Shoutrrr)](https://beszel.dev/guide/notifications/)
- [Pushover](https://beszel.dev/guide/notifications/pushover)
- [Shoutrrr services overview](https://containrrr.dev/shoutrrr/v0.8/services/overview/)

**VictoriaMetrics**
- [VictoriaMetrics Official Documentation](https://docs.victoriametrics.com/)
- [VictoriaMetrics Operator](https://docs.victoriametrics.com/operator/)
- [victoria-metrics-k8s-stack Helm Chart](https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack)
