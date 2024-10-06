# Kubernetes at Home on Bare Metal

> [!WARNING]  
> This is a WORK IN PROGRESS project, still experimental at this time.
> Things may change without notice.

Documentation, which is also a work in progress, is available here: https://o-be-one.github.io/kubernetes-at-home/.

## Proposal

This project aims to provide a simple and efficient way to run my own Kubernetes cluster on bare metal at home, with a focus on low-cost and high-performance.
There is usual controllers for main needs, like `cert-manager`, `external-dns`, `longhorn`, etc.
And the whole thing is operated from ArgoCD as a GitOps approach.

## Current state

- [x] Setup the project structure
- [x] Setup the main Kubernetes components
- [x] Setup a way to handle secrets from Git
- [x] Setup some Git workflows

## Future

Not ordered list with some ideas for future:

- [ ] Add image / diagram / illustration to the README
- [ ] Setup observability using VictoriaMetrics
- [ ] Setup a database operator
- [ ] Maybe migrate from Tailscale Funnel to Cloudflare Tunnel (cloudflared)
- [ ] Maybe add gvisor for better security and performance
- [ ] Maybe add trivy for vulnerability scanning
- [ ] Add a backup solution on the top of the one provided by Longhorn
- [ ] Complete upgrade documentation
- [ ] Complete troubleshooting documentation
- [ ] Complete any other documentation