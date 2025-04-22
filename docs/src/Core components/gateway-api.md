# Gateway API

## Installation

!!! Warning
    When upgrading from Gateway API v1.1.0 to v1.2.0, it's crucial to review the [changelog](https://github.com/kubernetes-sigs/gateway-api/releases/tag/v1.2.0). This document outlines significant changes and provides guidance on how to address them during the upgrade process.

As I put all of this in the cilium kustomization, you can just run:
`kubectl kustomize infra/cilium/ --enable-helm | kubectl apply -f -`

To verify if you have all CRDs installed and get their version, run:
`kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="gateway.networking.k8s.io")]}{.metadata.name}: {.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}{"\n"}{end}'`

Summary of the installation from documentation, can be obsolete:

Install Kubernetes Gateway APIs

- [https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/gateway-api/](https://docs.cilium.io/en/latest/network/servicemesh/gateway-api/gateway-api/)
- [https://gateway-api.sigs.k8s.io/guides/?h=crds#getting-started-with-gateway-api](https://gateway-api.sigs.k8s.io/guides/?h=crds#getting-started-with-gateway-api)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
```
If your gateway is stuck in "unknown" status, it may be because you don't have free IP available in your ip-pool.

## HTTP to HTTPS redirect

All HTTP routes are automatically redirected to HTTPS using a 302 status code. This redirection is managed by the `http-to-https-redirect` HTTPRoute, which is located in the same namespace as the shared gateway.

If you genuinely need your services to handle HTTP traffic, you have two options:

1. Remove the redirection route entirely. It's kind of a default behavior that will allow all your apps to be accessible via HTTP.

2. Keep the redirection as the default behavior, but customize specific routes. To do this, simply remove the `sectionName: shared-https` line from the HTTPRoute specifications of the apps you want to make accessible over HTTP.

This approach provides you with flexibility to manage HTTP and HTTPS traffic according to your specific needs.