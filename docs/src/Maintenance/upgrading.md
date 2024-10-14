# Upgrading

## Talos

Because of Longhorn, it's really important to use images from Talos factory that embeds following kernel extensions:
- siderolabs/iscsi-tools
- siderolabs/util-linux-tools

Controlplane will need to be upgraded first, then worker nodes.
If you have **only one controlplane node**, don't forget to always use the `--preserve` flag to keep data related to etcd.

!!! warning
    Longhorh requires you to use `-preserve` flag to keep data related to persistent volumes. Don't forget to use it for any nodes involved in Longhorn cluster.
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

## Longhorn