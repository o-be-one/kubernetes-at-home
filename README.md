# Kubernetes Cluster on Bare Metal

## DISCLAIMER
This is a WORK IN PROGRESS repository, really experimental at this time.
README needs work.

## Infrastructure

### Network

#### Hardwares

- Managed using Ubiquiti Unifi Dream Machine
- 2 Ubiquiti Flex Mini as "manageable" switches
- 1 Gbps network
- VLAN dedicated to Kubernetes

#### Addressing

- 192.168.200.101 to 192.168.200.103: Control Planes
- 192.168.200.111 to 192.168.200.112: Workers

### Machines

- 3 x Control Plane: Trigkey G4 with Intel N100 (4 cores, 4 threads), 16GB DDR4, and 500GB NVMe
- 2 x Workers: Beelink SER5 with AMD 5560U (6 cores, 12 threads), 16GB DDR4, and 500GB NVMe

### Software

Talos is one of the most impressive OS for Kubernetes, described as "Kubernetes OS". Talos expose an API that provides near experience to Kubernetes, and disable SSH. You configure it using their tool, talosctl, that helps generate config file that can be used in cloud-init or that can be applied using talosctl. It embeds several features like easy upgrades.

## Security

### Mozilla SOPS

Every sensitive information are encrypted using Mozilla SOPS with age.

### Helpful documentations

[KSOPS 4.3.1](https://github.com/viaduct-ai/kustomize-sops/tree/v4.3.1)

## Core components

### Cilium

Following is related to my first experience with Cilium, but since I've made a Kustomization to handle and deploy Cilium, I'll keep it here for future reference.

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install \
          cilium \
          cilium/cilium \
          --version 1.15.5 \
          --namespace kube-system \
          --set=ipam.mode=kubernetes \
          --set=kubeProxyReplacement=true \
          --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
          --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
          --set=cgroup.autoMount.enabled=false \
          --set=ingressController.enabled=true \
          --set=ingressController.default=true \
          --set=ingressController.loadbalancerMode=shared \
          --set=cgroup.hostRoot=/sys/fs/cgroup \
          --set=k8sServiceHost=localhost \
          --set=k8sServicePort=7445
```

Reminder: helm can upgrade deployed stack. Example:

```bash
helm upgrade cilium cilium/cilium --version 1.15.5 \
    --namespace kube-system \
    --reuse-values \
    --set ingressController.enabled=true \
    --set ingressController.loadbalancerMode=dedicated

helm upgrade cilium cilium/cilium --version 1.15.5 \
    --namespace kube-system \
    --reuse-values \
    --set ingressController.loadbalancerMode=shared

kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
``` 

And to get current values:
`helm get values cilium -n kube-system -o yaml`

### Gateway API

As I put all of this in the cilium kustomization, you can just run:
`kubectl kustomize infra/cilium/ --enable-helm | kubectl apply -f -`

To verify if you have all CRDs installed and get their version, run:
`kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="gateway.networking.k8s.io")]}{.metadata.name}: {.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}{"\n"}{end}'`

Summary of the installation from documentation, can be obsoleted:

Install Kubernetes Gateway APIs
- https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/gateway-api/
- https://gateway-api.sigs.k8s.io/guides/?h=crds#getting-started-with-gateway-api

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
```
If your gateway is stuck in "unknown" status, it may be because you don't have free IP available in your ip-pool.

### ArgoCD

Reach ArgoCD using kubectl proxy feature:
`kubectl port-forward svc/argocd-server -n argocd 8080:443`

To push your sops private key, use:
```bash
cat <your_key_file> | kubectl create secret generic sops-age --namespace=argocd \
--from-file=key.txt=/dev/stdin
```

### Longhorn

Longhorn will be our default storage solution. It was challenging to choose one but considering how small is my clsuter and how little experience I have with storage layer, this one looked the most relevant. It's also important to consider that it's still considered in beta and it comes with limitation when using with Talos (see [here](https://longhorn.io/docs/1.7.0/advanced-resources/os-distro-specific/talos-linux-support/)).

For Longhorn to work, we need to ensure that:
- kernel extensions are loaded on Talos nodes
- we mount /var/lib/longhorn on each node
- we use `--preserve` flag when upgrading Talos nodes to keep data related to persistent volumes

For all information, see [Longhorn docs](https://longhorn.io/docs/1.7.0/deploy/install/install-with-helm/).

## Upgrading

### Talos

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