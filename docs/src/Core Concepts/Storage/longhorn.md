# Longhorn

Longhorn is the primary storage solution for the cluster.

## Prerequisites (Talos)

For Longhorn to work correctly on Talos, the following requirements must be met:

- Specific kernel extensions must be included in the Talos image (especially `iscsi-tools` and `util-linux-tools`).
- The directory `/var/lib/longhorn` must be mounted on each node.
- The `--preserve` flag must be used when upgrading Talos nodes to avoid data loss related to persistent volumes.

See the [Talos Image Factory](https://factory.talos.dev/) to generate images with the required extensions.

## Deployment

Longhorn is deployed declaratively via Kustomize in `core/longhorn-system/`.

## Useful Resources

- [Longhorn Official Documentation](https://longhorn.io/docs/)
- [Install Longhorn with Helm](https://longhorn.io/docs/latest/deploy/install/install-with-helm/)
- [Longhorn + Talos specific considerations](https://longhorn.io/docs/latest/advanced-resources/os-distro-specific/talos-linux-support/)
- [Upgrading Longhorn](https://longhorn.io/docs/latest/deploy/upgrade/upgrade-with-helm/)

## Complementary Storage

Synology CSI is used alongside Longhorn to provide additional storage backed by the home NAS.  
See [Synology CSI](synology-csi.md).
