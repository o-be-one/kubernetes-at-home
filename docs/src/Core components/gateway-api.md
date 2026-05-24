# Gateway API

Gateway API is provided by Cilium (no separate ingress controller).

## Important note on exposure

All HTTPRoutes using hostnames under `*.menia.cc` are only reachable from the local LAN.  
Public internet access to applications is provided exclusively through Cloudflare Tunnels (see `core/cloudflared/` and per-app `cloudflared.yaml` files).

## Installation / Update

All CRDs and the shared Gateway are deployed as part of the Cilium kustomization:

```bash
kubectl kustomize infra/cilium/ --enable-helm | kubectl apply -f -
```

This includes:
- Standard + experimental Gateway API CRDs (v1.2.0)
- `GatewayClass` named `cilium`
- `Gateway` named `shared-gateway` in the `default` namespace (uses `wildcard-menia-cc-tls` certificate from cert-manager)
- HTTP → HTTPS 302 redirect `HTTPRoute`

## Verify CRDs

```bash
kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="gateway.networking.k8s.io")]}{.metadata.name}: {.metadata.annotations.gateway\.networking\.k8s\.io/bundle-version}{"\n"}{end}'
```

## HTTP to HTTPS redirect

All traffic on the `shared-http` listener is redirected to HTTPS by the `http-to-https-redirect` HTTPRoute (defined in `infra/cilium/gateway.yaml`).

If you need to allow plain HTTP for a specific app:

- Do **not** include `sectionName: shared-http` in that app's HTTPRoute, or
- Remove the redirect route entirely (not recommended for production).

## Troubleshooting

If a Gateway stays in "Unknown" or "Pending":

- Check that a free IP exists in the CiliumLoadBalancerIPPool (`infra/cilium/ip-pool.yaml`)
- Verify L2 announcement policy is active

## References

- Current implementation: `infra/cilium/gateway.yaml`
- Cilium Gateway API docs: https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/
- Upstream Gateway API: https://gateway-api.sigs.k8s.io/

Older direct CRD `kubectl apply` commands are no longer needed (they are now part of the Cilium kustomize).
