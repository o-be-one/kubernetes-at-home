# Installation

This page covers bootstrapping a new Talos Linux node or the full cluster using the configurations stored in this repository.

## Prerequisites

- Talos ISO (or ISO + kernel extensions from the [Talos Image Factory](https://factory.talos.dev/))
- `talosctl` CLI installed
- Age private key + SOPS (`sops`) for decrypting the machine configs
- `kubectl` + `kustomize` (for applying workloads after the cluster is up)

The recommended Talos images for this cluster include the following kernel extensions (required for Longhorn + Synology CSI):

- `siderolabs/iscsi-tools`
- `siderolabs/util-linux-tools`

See the preset links in [Longhorn](../Core components/longhorn.md) and [Upgrading](../Maintenance/upgrading.md).

## Machine configuration

All Talos machine configs are stored encrypted in `infra/`:

- `controlplane.enc.yaml`
- `worker.enc.yaml`
- `secrets.enc.yaml` (cluster secrets bundle)

Plain `.yaml` versions are generated locally and are **gitignored**.

To obtain a usable config:

```bash
sops -d infra/controlplane.enc.yaml > infra/controlplane.yaml
sops -d infra/worker.enc.yaml > infra/worker.yaml
```

You can then use the decrypted files with `talosctl`:

- Initial install on bare metal: `talosctl apply-config --insecure -n <node-ip> -f infra/controlplane.yaml`
- Update existing node: `talosctl apply-config -n <node-ip> -f infra/controlplane.yaml`

## Cluster secrets

The `secrets.enc.yaml` contains the sensitive cluster-wide secrets (tokens, CA keys, etc.). These are used when (re)generating node configs.

## First-time cluster bootstrap flow (high level)

1. Boot the Talos ISO on the intended control plane nodes.
2. Decrypt and apply the controlplane config(s).
3. Bootstrap the first control plane (`talosctl bootstrap`).
4. Add remaining control planes and workers using their respective configs.
5. Once the cluster is up, apply the GitOps layer:
   ```bash
   kubectl kustomize core/argocd/ --enable-helm | kubectl apply -f -
   ```

## Next steps after installation

- Configure ArgoCD access and push the age key (see [ArgoCD](../Core components/argocd.md))
- Let ArgoCD deploy the rest of `core/`, `operators/`, and `apps/`

For ongoing node upgrades (Talos or Kubernetes), see [Upgrading](../Maintenance/upgrading.md).
