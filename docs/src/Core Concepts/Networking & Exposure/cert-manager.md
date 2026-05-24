# cert-manager

cert-manager is used to automatically provision and manage TLS certificates **exclusively for the internal LAN domain** (`*.menia.cc`).

## Purpose

The goal is to have valid HTTPS certificates for services exposed via the Gateway API on `*.menia.cc`. These routes are only reachable from the local network.

Public workloads (exposed via Cloudflare Tunnels) use a different domain (e.g. `*.btrcloud.com`) and rely on Cloudflare's own TLS certificates. cert-manager is **not** used for public services.

## Deployment

cert-manager is deployed in `core/cert-manager/` using the official manifests (version 1.14.5).

Key customizations:
- The feature gate `ExperimentalGatewayAPISupport=true` is enabled to support Gateway API certificates.
- A `ClusterIssuer` named `letsencrypt-prod` is created.

## Certificate issuance (LAN only)

The `letsencrypt-prod` ClusterIssuer is configured to issue certificates for `*.menia.cc` using the **DNS-01** challenge with Cloudflare.

- It uses a Cloudflare API token stored in a secret (`cloudflare-menia-cc-api-token-secret`), managed via SOPS + KSOPS.
- This allows obtaining wildcard certificates for the internal domain.

## Usage

Services that need TLS on `*.menia.cc` (via Gateway API or Ingress) reference this issuer.

Example annotation:
```yaml
cert-manager.io/cluster-issuer: letsencrypt-prod
```

This is used on the shared Gateway defined in `infra/cilium/gateway.yaml`.

## References

- [Official cert-manager documentation](https://cert-manager.io/docs/)
- [Gateway API support in cert-manager](https://cert-manager.io/docs/usage/gateway/)
- [DNS01 challenge with Cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/)
