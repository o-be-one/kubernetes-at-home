# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Kubernetes-at-home GitOps repository using ArgoCD to manage a bare metal Kubernetes cluster running on Talos OS. The infrastructure follows a declarative approach with Kustomize for application management and Mozilla SOPS with age encryption for secrets management.

## Key Architecture Components

- **GitOps Controller**: ArgoCD manages all deployments from this Git repository
- **Network**: Cilium CNI with Gateway API for ingress (no traditional Ingress controllers)
- **Storage**: Longhorn for persistent volumes, Synology CSI for NAS storage
- **Security**: Mozilla SOPS with age encryption for all secrets (*.enc.yaml files)
- **Public Access**: Cloudflared tunnels for exposing workloads to the public internet
- **OS**: Talos OS (API-managed, no SSH access)

## Directory Structure

```
apps/           # Application deployments (managed by ArgoCD ApplicationSet)
core/           # Core cluster components (ArgoCD, cert-manager, DNS, etc.)
infra/          # Infrastructure layer (Cilium, Talos configs)
operators/      # Kubernetes operators (MariaDB, CloudNativePG)
examples/       # Example configurations
docs/           # MkDocs documentation
```

## Common Development Commands

### Documentation
```bash
# Serve documentation locally
cd docs/
pip install -r requirements.txt
mkdocs serve
```

### Secret Management
All secrets use SOPS encryption with age. Encrypted files have `.enc.yaml` extension.

```bash
# Decrypt a secret for viewing (do not commit decrypted files)
sops -d path/to/secret.enc.yaml

# Edit encrypted secret
sops path/to/secret.enc.yaml

# Encrypt a new secret
sops -e path/to/secret.yaml > path/to/secret.enc.yaml
```

### Kubernetes Operations
```bash
# Apply Kustomize configurations
kubectl apply -k apps/app-name/

# View ArgoCD applications
kubectl get applications -n argocd

# Check application sync status
kubectl get app -n argocd app-name -o jsonpath='{.status.sync.status}'
```

## Important Patterns

### Kustomization Structure
Every deployable component has a `kustomization.yaml` that defines:
- Resources (YAML manifests, Helm charts, or remote URLs)
- ConfigMap/Secret generators
- Patches and overlays
- Namespace targeting

### ArgoCD ApplicationSets
Applications are automatically discovered via ApplicationSets in `/core/argocd/`:
- `appset-apps.yaml`: Apps from `apps/` directory
- `appset-core.yaml`: Core components from `core/` directory
- `appset-operators.yaml`: Operators from `operators/` directory

### Secret Management Pattern
1. Create plain YAML secret
2. Encrypt with SOPS: `sops -e secret.yaml > secret.enc.yaml`
3. Reference encrypted file in `kustomization.yaml`
4. KSOPS plugin decrypts during Kustomize build

### Public Access with Cloudflared
Applications exposed to the public internet use Cloudflared tunnels:
- Each public app includes a `cloudflared.yaml` configuration
- Tunnels are managed via Cloudflare dashboard
- HTTPRoute resources reference the tunnel endpoints

### Gateway API Instead of Ingress
Use `HTTPRoute` resources instead of `Ingress`:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
spec:
  parentRefs:
  - name: cilium-gateway
    namespace: kube-system
  hostnames:
  - app.domain.com
  rules:
  - backendRefs:
    - name: app-service
      port: 80
```

## Testing and Validation

No traditional testing frameworks - validation happens through:
1. Kustomize build validation: `kubectl kustomize path/`
2. ArgoCD sync status monitoring
3. Application health checks in ArgoCD UI
4. Application-specific resource status: `kubectl get deployment,service,configmap -l app=app-name`

## Security Notes

- Never commit unencrypted secrets
- All `.enc.yaml` files are encrypted with Mozilla SOPS
- Use `secret-generator.yaml` to identify sensitive data
- Talos OS uses API-only access (no SSH)
- External access via Cloudflare tunnels and Tailscale

## Repository Conventions

- Use `kustomization.yaml` for all deployments
- Encrypt sensitive data with SOPS before committing
- Follow the `apps/`, `core/`, `infra/`, `operators/` structure
- Use Gateway API (`HTTPRoute`) instead of Ingress resources
- Include `cloudflared.yaml` for applications requiring public access
- Document infrastructure changes in `/docs/src/`
