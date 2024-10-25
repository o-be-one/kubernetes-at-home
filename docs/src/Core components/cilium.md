# Cilium

## Prerequisites

- Cilium CLI: check cilium status

## Installation

https://docs.cilium.io/en/stable/installation/k8s-install-helm/

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

## Upgrade

Reminder: helm can upgrade deployed stack. Example:

```bash
helm upgrade cilium cilium/cilium --version 1.15.5 \
    --namespace kube-system \
    --reuse-values \
    --set ingressController.loadbalancerMode=shared

kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
``` 

And to get current values:
`helm get values cilium -n kube-system -o yaml`