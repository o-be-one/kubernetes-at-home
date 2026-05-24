# Synology CSI

Synology CSI allows using storage from the Synology NAS directly from Kubernetes via the CSI (Container Storage Interface) protocol. It complements Longhorn by providing a second StorageClass with different characteristics (large capacity, snapshots available on the NAS, performance suitable for certain workloads).

## Why use it?

- Longhorn is the primary storage (block, high availability, good Kubernetes integration).
- The Synology NAS provides large capacity and an external backup/snapshot solution.
- Some workloads benefit from having persistent volumes directly on the NAS (e.g., media, backups, large datasets).

## Prerequisites

For Synology CSI to work correctly on this Talos cluster, the following are required:

- The appropriate Talos kernel extensions must be loaded (iscsi-tools and util-linux-tools).
- The `synology-csi-node` DaemonSet is patched to use the correct `iscsiadm` path (`/usr/local/sbin/iscsiadm`) because Talos does not place it in the usual location.
- A user account with the necessary permissions must exist on the DSM (used via credentials in the secret).

## Deployment

The driver is deployed via Kustomize in `core/synology-csi/`:

- It fetches the official Synology CSI manifests (version for Kubernetes 1.20+).
- It applies a Talos-specific patch to the `synology-csi-node` DaemonSet.
- It creates the `syno-storage` StorageClass (not the default).
- DSM credentials are injected via a secret generator (`secret-generator.yaml` + `secret.enc.yaml`).

The created StorageClass is named `syno-storage` and uses `ext4` by default.

## Usage

To use this storage, simply specify `storageClassName: syno-storage` in your PersistentVolumeClaims.

Example:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-nas-volume
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: syno-storage
  resources:
    requests:
      storage: 50Gi
```

## References

- [Synology CSI Official Repository](https://github.com/SynologyOpenSource/synology-csi)
- [Synology CSI Documentation](https://github.com/SynologyOpenSource/synology-csi/tree/main/docs)
- [Known Talos + iscsiadm Issue](https://github.com/SynologyOpenSource/synology-csi/issues/89)
- [Synology CSI StorageClass Example](https://github.com/SynologyOpenSource/synology-csi/blob/main/deploy/kubernetes/v1.20/storage-class.yml)
