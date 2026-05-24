# Cloudflared (Cloudflare Tunnel Ingress Controller)

This component provides public internet exposure for selected applications using Cloudflare Tunnels. It is the **only** way to make services publicly accessible from the internet in this setup.

All HTTPRoutes under `*.menia.cc` are restricted to LAN access only.

## Architecture

Instead of running a classic `cloudflared` daemon per application, this cluster uses the **Cloudflare Tunnel Ingress Controller**.

- The controller runs as a Kubernetes Deployment.
- It watches for `Ingress` resources that use the `cloudflare-tunnel` IngressClass.
- When such an Ingress is created, the controller automatically creates the corresponding route in the Cloudflare Tunnel.

This approach is more Kubernetes-native than managing tunnels manually.

## Deployment

The controller is deployed via Helm in `core/cloudflared/` using the chart `cloudflare-tunnel-ingress-controller` (from `https://helm.strrl.dev`).

Key configuration points:

- It connects to a specific Cloudflare Tunnel using credentials stored in the `cloudflared-api` secret.
- The secret contains the Cloudflare Account ID, Tunnel Name, and API Token (managed via SOPS + KSOPS).

The controller runs in the `cloudflared-ingress-controller` namespace.

## Exposing an application publicly

To expose an app to the public internet:

1. Create an `Ingress` resource in the application's namespace.
2. Set `ingressClassName: cloudflare-tunnel`.
3. Define the desired public hostname (usually under `btrcloud.com` or another domain managed in Cloudflare).
4. Point to the internal Kubernetes Service.

Example (`apps/glance/cloudflared.yaml`):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: glance-cloudflared
spec:
  ingressClassName: cloudflare-tunnel
  rules:
    - host: glance.btrcloud.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: glance
                port:
                  number: 8080
```

Once applied, the controller will make `https://glance.btrcloud.com` publicly available (with Cloudflare's security features: WAF, DDoS protection, caching, etc.).

## Security considerations

- Public access is always terminated at Cloudflare (HTTPS).
- Cloudflare security features (WAF, rate limiting, etc.) are enabled by default on the domain.
- Only explicitly created Ingress resources with the correct class become public.
- The Cloudflare API token used by the controller has limited permissions (only tunnel management).

## References

- [Cloudflare Tunnel Ingress Controller (Helm chart)](https://github.com/STRRL/cloudflare-tunnel-ingress-controller)
- [Cloudflare Tunnels – Getting Started](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/)
- [Cloudflare Tunnel Ingress Controller Documentation](https://github.com/STRRL/cloudflare-tunnel-ingress-controller/blob/main/README.md)
- [Cloudflare API Token Permissions](https://developers.cloudflare.com/fundamentals/api/reference/permissions/)
