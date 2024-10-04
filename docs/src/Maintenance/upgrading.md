# Upgrading

## Talos

Because of Longhorn, it's really important to use images from Talos factory that embeds following kernet extensions:
- siderolabs/iscsi-tools
- siderolabs/util-linux-tools

And again, because of Longhorn, it's upgrade needs to have `--preserve` flag to keep data related to persistent volumes or you will need to rebuild them.

References:
- [Longhorn docs for Talos](https://longhorn.io/docs/1.7.0/advanced-resources/os-distro-specific/talos-linux-support/)
- [Image factory (preset)](https://factory.talos.dev/?arch=amd64&board=undefined&cmdline-set=true&extensions=-&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Futil-linux-tools&platform=metal&target=metal)

Example of upgrade command:
```bash
talosctl upgrade -n 192.168.200.112 --image factory.talos.dev/installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.7.6 --preserve
```

## Cilium

## Longhorn