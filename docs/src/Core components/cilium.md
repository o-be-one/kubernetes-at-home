# Cilium

Cilium is the CNI and also provides the Gateway API ingress controller for the cluster.

## Current deployment

Everything is managed declaratively via Kustomize:

```bash
kubectl kustomize infra/cilium/ --enable-helm | kubectl apply -f -
```

The definition lives in `infra/cilium/kustomization.yaml`:

- Gateway API CRDs (v1.2.0 standard + experimental)
- Cilium Helm chart (v1.16.3) using `values.yaml`
- CiliumLoadBalancerIPPool (`ip-pool.yaml`)
- CiliumL2AnnouncementPolicy (`announce.yaml`)
- GatewayClass + Gateway + HTTP redirect (`gateway.yaml`)

## Key settings (from values.yaml)

- `kubeProxyReplacement: true`
- Gateway API enabled (`gatewayAPI.enabled: true`)
- Ingress controller enabled in shared load-balancer mode
- Hubble + UI + relay enabled
- L2 announcements for LoadBalancer IPs
- Custom securityContext capabilities required for Talos
- `k8sServiceHost: localhost` + port 7445 (Talos specific)

## Useful commands

Check Cilium status:
```bash
cilium status
cilium connectivity test   # (requires the privileged namespace from infra/cilium/namespace.yaml)
```

See installed Gateway API CRD versions:
```bash
kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="gateway.networking.k8s.io")]}{.metadata.name}: {.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}{"\n"}{end}'
```

## Upgrade

Update the version in `infra/cilium/kustomization.yaml` (helmCharts section) and re-apply the kustomize command above.

After Cilium changes, it is often useful to restart the cilium pods:
```bash
kubectl -n kube-system rollout restart ds/cilium
kubectl -n kube-system rollout restart deployment/cilium-operator
```

## Historical note

The old pure-Helm install commands are kept below only for reference (pre-Kustomize era).

```bash
# Old way (no longer used)
helm install cilium cilium/cilium --version 1.15.5 \
  --namespace kube-system \
  ... (many --set flags now in values.yaml)
```

See the live manifests in `infra/cilium/` for the current truth.
