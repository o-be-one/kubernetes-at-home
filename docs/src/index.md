# Home

!!! warning
    **WORK IN PROGRESS!** At this time, even if most components are ready, project itself and documentation are really experimental.

!!! info
    This project is made to be a half a playground for learning and experimenting with Kubernetes and half a production to enjoy independancy. If you see any error or enhancement opportunity, please open an issue or a pull request so I can fix it or learn from your experience ˆˆ.

## Why I do that?

I host my own servers since more than 10 years, mostly for non profit organizations and communities. I had to pay monthly fees for non load balanced servers hosted with different providers. I've always been into the topic of self-reliance, and more recently, the topic of self-hosting.

Since few years, high speed internet connection came to be more available and affordable. I started to host my own servers at home and wanted to take advantage of a technology stack built to be resilient and scalable at its core. Overall, with UPS batteries, the only SPOF is the Internet connection. I would not say it's cheaper than paying for hosting, but I have more power to host anything and more room to add servers for hard workloads like AI.

With my Kubernetes journey, I wanted to be more involved into opensource projects and practice more GitHub. I really hope this little project will help you along your first steps into _Kubernetes at Home_.

## Infrastructure

### Hardware

My network is entirely managed using Ubiquiti Unifi products:

- 1x Unifi Dream Machine
- 2x Unifi Flex Mini

And the cluster hardware is:

- 3 x Control Plane: Trigkey G4 with Intel N100 (4 cores, 4 threads), 16GB DDR4, and 500GB NVMe
- 2 x Workers: Beelink SER5 with AMD 5560U (6 cores, 12 threads), 16GB DDR4, and 500GB NVMe - I may had a third at some point
- 1 x NAS: Synology DS423 with 4x8tb disks in RAID1

### Network

My Internet connection is 3 Gbps down / 3 Gbps up with a dynamic public IP. So I added a VPN solution made to open HTTP access to public ([Tailscale funnel](https://tailscale.com/) (HTTP(s) only) / [Cloudflare Argo Tunnel](https://www.cloudflare.com/) (HTTP(s) and TCP in beta iirc). We will see later how I deal with that.

I've provisionned a dedicated VLAN for the cluster, with DHCP and LAN DNS managed by the Unifi Dream Machine. Folowing are the IPs used:

- 192.168.200.101 to 192.168.200.103: Control Planes
- 192.168.200.111 to 192.168.200.112: Workers

In cluster network is entirely managed using Cilium.

### Software

I've challenged several solutions. My first experience with Kubernetes was with Alpine Linux and k3s, then I moved to a solution available on GitHub to automatically [deploy a cluster on Hetzner using Terraform](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner). The solution for Hetzner was using [MicroOS from SUSE](https://microos.opensuse.org/). When I've looked why they would use MicrOS, I've discovered that some OS are surnamed "Container OS" and started to dig into [Flatcar](https://www.flatcar.org/) and alternatives. Then, a friend told me about another option...

And that's how I ended up with [Talos OS](https://www.talos.dev/). Talos is one of the most impressive OS for Kubernetes, described as "Kubernetes OS". Talos expose an API that provides similar experience to Kubernetes where you control it using an API. SSH is not installed on it, instead you configure the system using their cli named talosctl. Talos CLI will also helps you to generate config files that can be used in cloud-init or that can be pushed to an idling system waiting for orders.

## Security

### Mozilla SOPS + KSOPS

Every sensitive information are encrypted using [Mozilla SOPS](https://github.com/getsops/sops) with age plus [KSOPS](https://github.com/viaduct-ai/kustomize-sops) to handle those secrets from the Kubernetes cluster during Kustomize builds.

## Core Concepts

The major architectural choices are documented in the dedicated **[Core Concepts](Core%20Concepts/GitOps/argocd.md)** section:

- GitOps with ArgoCD
- Networking & Exposure (Cilium, Gateway API, Cloudflared, external access)
- Storage (Longhorn + Synology CSI)
- Security

## Operators

Kubernetes operators (CloudNativePG, MariaDB operator, VictoriaMetrics, etc.) are deployed via the `operators/` directory and the `operators` + `operators-serverside` ApplicationSets.

See [Operators overview](Operators/operators.md) for the current list and deployment notes.

## Examples

Preview, demo, and experimental workloads live in `examples/`. They are not auto-deployed by the main ApplicationSets (useful for testing and PR previews).

See [Examples](Examples/examples.md).

## Repository Structure

The project is a pure declarative GitOps repository. Source of truth = the YAML files + ApplicationSets (not prose).

| Folder          | Description |
| ---             | --- |
| `apps/`         | User workloads. Each subdirectory = one ArgoCD Application (namespace = dir basename). Includes `apps/serverside/*` for ServerSideApply workloads. |
| `core/`         | Essential cluster components (ArgoCD, Cilium is under infra, Longhorn, cert-manager, external-dns, cloudflared, netdata, etc.). |
| `operators/`    | Kubernetes operators (CNPG, MariaDB, VictoriaMetrics, ...). Includes `operators/serverside/*`. |
| `infra/`        | Infrastructure configs. Contains the encrypted Talos controlplane and worker machine configs (`controlplane.enc.yaml`, `worker.enc.yaml`, `secrets.enc.yaml`) plus the `infra/cilium/` subdirectory (CNI + Gateway + L2 announcements). |
| `examples/`     | Preview / non-production examples (not auto-deployed by the main ApplicationSets). |
| `docs/`         | MkDocs documentation sources (`src/`). |

Deployment is driven centrally by ApplicationSets in `core/argocd/`:

- `appset-apps.yaml`
- `appset-core.yaml`
- `appset-operators.yaml`
- `appset-cilium.yaml`

**Adding a new app**: create `apps/<name>/kustomization.yaml` (with resources, configMapGenerators, optional `secret-generator.yaml` + `*.enc.yaml`), commit. ArgoCD discovers it automatically.

**In the future** I may switch to a per-directory `applicationset.yaml` files.

## Local development & validation

- Render any component: `kubectl kustomize <path>/ --enable-helm`
- Edit secrets: `sops path/to/xxx.enc.yaml` (only `*.enc.yaml` are committed)
- Talos machine configs: stored encrypted as `infra/*.enc.yaml`; decrypt with sops when feeding to `talosctl`

## Future / Roadmap

Check the [GitHub issues](https://github.com/o-be-one/kubernetes-at-home/issues) for the current roadmap.
