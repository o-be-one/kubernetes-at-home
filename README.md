# Kubernetes at Home on Bare Metal

> [!WARNING]  
> This is a WORK IN PROGRESS project, experimental at this time.
> Things may change without notice.

Documentation, which is also a work in progress and a bit lower priority for now, is available here: https://o-be-one.github.io/kubernetes-at-home/.

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
- storage using Synology NAS is setup and running
- use of Cloudflare tunnel to open choosen app to public
- use of Tailscale and playit.gg to access UDP ports from outside
- a minor part of security was introduced (non privileged)
- Postgres database operator is setup and deployed

## Future

Please check issues to know more about the roadmap :).