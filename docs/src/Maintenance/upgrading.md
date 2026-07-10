# Upgrading

For backup strategy and etcd recovery, see [Backup](backup.md).

## Talos

Because of Longhorn, it's really important to use images from Talos factory that embeds following kernel extensions:

- siderolabs/iscsi-tools (required for Longhorn and Synology CSI)
- siderolabs/util-linux-tools (required for Longhorn)
- siderolabs/gvisor (security - but not working after Talos 1.8.3 as they use containerd v2)
- siderolabs/intel-i915 (optional, if Intel iGPU)

Controlplane will need to be upgraded first, then worker nodes.
If you have **only one controlplane node**, don't forget to always use the `--preserve` flag to keep data related to etcd.

!!! warning
    Longhorn requires you to use `--preserve` flag to keep data related to persistent volumes. Don't forget to use it for any nodes involved in Longhorn cluster.
    Failure to do so will result in data loss.

Example of upgrade command:
```bash
talosctl upgrade -n 192.168.200.112 --image factory.talos.dev/installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.7.6 --preserve
```

References:

- [Talos upgrade](https://www.talos.dev/v1.7/talos-guides/upgrading-talos/)
- [Longhorn docs for Talos](https://longhorn.io/docs/1.7.0/advanced-resources/os-distro-specific/talos-linux-support/)
- [Image factory (preset)](https://factory.talos.dev/?arch=amd64&board=undefined&cmdline-set=true&extensions=-&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Futil-linux-tools&platform=metal&target=metal)

## Kubernetes

Upgrading Kubernetes is quite straightforward, just run:
```bash
talosctl upgrade-k8s --to 1.31.1 -n 192.168.200.101
```

This should upgrade all nodes in the cluster.

References:

- [Kubernetes upgrade](https://www.talos.dev/v1.7/kubernetes-guides/upgrading-kubernetes/)

## Cilium

Cilium is upgraded by changing the version in `infra/cilium/kustomization.yaml` (under `helmCharts`) and re-applying the kustomize:

```bash
kubectl kustomize infra/cilium/ --enable-helm | kubectl apply -f -
```

After the upgrade, restart the Cilium components:

```bash
kubectl -n kube-system rollout restart ds/cilium
kubectl -n kube-system rollout restart deployment/cilium-operator
```

See [Cilium](../Core%20Concepts/Networking%20&%20Exposure/cilium.md) for the current version and values.

### One minor version at a time

!!! danger "Never skip minor versions"
    Cilium only supports/tests upgrades **between consecutive minor releases** (e.g. `1.16 → 1.17 → 1.18`). Jumping several minors at once (e.g. `1.16 → 1.19`) is untested and can leave the cluster in a broken state.

    Bump the `version:` field **one minor at a time**, wait for ArgoCD to sync and for all `cilium` / `cilium-operator` pods to become healthy at each step, then move to the next minor. Always target the **latest patch** of a minor before moving up.

Always read the version-specific **Upgrade Notes** for every minor you cross (not just the target one): [Cilium Upgrade Guide](https://docs.cilium.io/en/stable/operations/upgrade/).

### Gateway API CRDs must match the Cilium version

The Gateway API CRD version pinned in `resources:` of `infra/cilium/kustomization.yaml` is **not** "use the latest available". It must match the version the Cilium controller is built against, otherwise the schema/validation can diverge from what Cilium expects. Bump the CRD URLs in lockstep with each Cilium minor:

| Cilium  | Gateway API CRDs |
|---------|------------------|
| 1.16.3  | v1.1.0 (repo runs v1.2.0 — slightly ahead but compatible) |
| 1.17.17 | v1.2.0 |
| 1.18.11 | v1.3.0 |
| 1.19.5  | v1.4.1 |

Reference: the "Prerequisites" section of the Cilium Gateway API docs for the target version (e.g. [v1.19](https://docs.cilium.io/en/v1.19/network/servicemesh/gateway-api/gateway-api/)).

### CRD `apiVersion` migrations (breaking)

Some Cilium CRDs graduate from `v2alpha1` to `v2` and the old version stops being served in a later release. Migrate the manifests **before** the upgrade that removes them:

- **`CiliumLoadBalancerIPPool`** (`ip-pool.yaml`): `cilium.io/v2alpha1` → `cilium.io/v2` is required for **1.19**.
- **`CiliumL2AnnouncementPolicy`** (`announce.yaml`): still `v2alpha1` as of 1.19 — no change needed yet, but re-check on future bumps.
- BGP CRDs (`CiliumBGPPeeringPolicy` / BGPv1) were removed in 1.19 — not used here (this cluster uses L2 announcements), so no action.

### Other things to double-check for this cluster

- **kube-proxy replacement**: several `--enable-node-port` / `--enable-host-port` / `--enable-external-ips` flags were removed in 1.19; the features are only active via `kubeProxyReplacement: true`. This repo already sets `kubeProxyReplacement: true`, so no action — just don't remove it.
- **L7 DNS policies**: in 1.19 the `**` wildcard in DNS patterns now matches multiple subdomains. Audit any `CiliumNetworkPolicy` using `**.` patterns.
- **Helm values drift**: when rendering the chart, watch for renamed/deprecated values reported by Cilium's upgrade notes for the crossed minors.

## Longhorn

Longhorn upgrades are performed via its own Helm chart or the manifests under `core/longhorn-system/`.

Always follow the official Longhorn upgrade documentation for the target version, especially the notes about Talos and the `--preserve` flag during node upgrades.

Reference: [Longhorn upgrade guide](https://longhorn.io/docs/1.7.0/deploy/upgrade/upgrade-with-helm/)

## References

**Talos**
- [Talos Upgrade Guide](https://www.talos.dev/v1.7/talos-guides/upgrading-talos/)
- [Talos + Longhorn considerations](https://longhorn.io/docs/latest/advanced-resources/os-distro-specific/talos-linux-support/)

**Kubernetes**
- [Kubernetes Upgrade with Talos](https://www.talos.dev/v1.7/kubernetes-guides/upgrading-kubernetes/)

**Cilium**
- [Cilium Upgrade Documentation](https://docs.cilium.io/en/stable/operations/upgrade/)

**Longhorn**
- [Longhorn Upgrade Guide](https://longhorn.io/docs/latest/deploy/upgrade/upgrade-with-helm/)
