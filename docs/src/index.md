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
- (future) why not a NAS to keep backups and stateless workload data locally as well

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

### Mozilla SOPS

Every sensitive information are encrypted using [Mozilla SOPS](https://github.com/getsops/sops) with age plus [KSOPS](https://github.com/viaduct-ai/kustomize-sops) to handle those secrets from the Kubernetes cluster.

## Core components

### Network (Cilium)

I've often heard about Cilium from a friend who's BPF and XDP passionate, so I wanted to try it. What's interesting with Cilium is that they provide a Kubernetes experience with a strong focus on network, with lot of features and lot of tools. This cluster uses Cilium to manage network and to manage ingress in Gateway API format.

[Know more about how I setup and maintain Cilium](Core%20components/cilium/).

### Ingress (Gateway API)

My first experiences with ingress have been using Ingress Controller from Traefik Labs. I've used Traefik for a while with Docker and really loved it. And then I heard about Gateway API, which is in beta under Cilium. As Kubernetes push to standardize Gateway API, I wanted to try it; and because I'm using Cilium, it was a good fit.

[Know more about how I setup and maintain Gateway API](Core%20components/gateway-api.md).

### GitOps (ArgoCD)

I've heard about ArgoCD at some point (who into Kubernetes did not?) and I used it in a past professional experience. I really enjoyed the tool so I decided to use it for this cluster. GitOps is interesting as it allows to have a declarative approach to infrastructure and application management from a source of truth.

[Know more about how I setup and maintain ArgoCD](Core%20components/argocd.md).

### Storage (Longhorn)

Longhorn will be our default storage solution. It was challenging to choose one but considering how small is my clsuter and how little experience I have with storage layer, this one looked the most relevant. It's also important to consider that it's still considered in beta and comes with limitation when used with Talos (see [here](https://longhorn.io/docs/1.7.0/advanced-resources/os-distro-specific/talos-linux-support/)).

[Know more about how I setup and maintain Longhorn](Core%20components/longhorn.md).