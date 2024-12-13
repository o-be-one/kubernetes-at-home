# Longhorn

## Prerequisites

For Longhorn to work, we need to ensure that:
- kernel extensions are loaded on Talos nodes (see [Image factory (preset)](https://factory.talos.dev/?arch=amd64&board=undefined&cmdline-set=true&extensions=-&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Futil-linux-tools&platform=metal&target=metal))
- we mount /var/lib/longhorn on each node
- we use `--preserve` flag when upgrading Talos nodes to keep data related to persistent volumes

## Installation

For all installation information, see [Longhorn docs](https://longhorn.io/docs/1.7.0/deploy/install/install-with-helm/).