# Kubernetes at Home on Bare Metal

> [!WARNING]  
> This is a WORK IN PROGRESS project, still experimental at this time.
> Things may change without notice.

Documentation, which is also a work in progress, is available here: https://o-be-one.github.io/kubernetes-at-home/.

## Proposal

This project aims to provide a simple and acceptable way to run my own Kubernetes cluster on bare metal at home, with a focus on *"low-cost"* and high-performance.
There is usual controllers for main needs, like `cert-manager`, `external-dns`, `longhorn`, etc.
And the whole thing is operated from ArgoCD as a GitOps approach.

## Current state

- project structure looks good to me
- main Kubernetes components are setup and running
- secrets are handled and encrypted
- gitops is working using ArgoCD
- few apps are deployed
- storage using Longhorn is setup and running
- use of Cloudflare tunnel to open choosen app to public

## Future

Not ordered list with some ideas for future:

- [ ] Add image / diagram / illustration to the README
- [ ] Setup observability using VictoriaMetrics
- [ ] Setup a database operator
- [ ] Maybe add gvisor for better security and performance
- [ ] Maybe add trivy for vulnerability scanning
- [ ] Complete upgrade documentation
- [ ] Complete troubleshooting documentation
- [ ] Complete any other documentation