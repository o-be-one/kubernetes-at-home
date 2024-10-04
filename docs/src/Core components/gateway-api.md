# Gateway API

## Installation
As I put all of this in the cilium kustomization, you can just run:
`kubectl kustomize infra/cilium/ --enable-helm | kubectl apply -f -`

To verify if you have all CRDs installed and get their version, run:
`kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="gateway.networking.k8s.io")]}{.metadata.name}: {.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}{"\n"}{end}'`

Summary of the installation from documentation, can be obsolete:

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