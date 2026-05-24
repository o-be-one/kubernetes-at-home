# AGENTS.md

This is a declarative GitOps repo for a Talos Linux bare-metal K8s cluster. No build/test/lint commands; changes land via git → ArgoCD syncs.

## Structure & Ownership
- `apps/**` + `apps/serverside/*`: user workloads (ApplicationSet `apps`/`apps-serverside` in core/argocd/appset-apps.yaml). Each subdir = one ArgoCD Application (namespace = basename).
- `core/**`: core components (ArgoCD, cert-manager, Longhorn, external-dns, etc.) via `appset-core.yaml`.
- `operators/**` + `operators/serverside/*`: operators (CNPG, MariaDB, etc.) via `appset-operators.yaml`.
- `infra/cilium`: CNI + Gateway (via `appset-cilium.yaml` under infra project).
- `examples/`: previews / non-prod examples (not auto-deployed by main sets).
- `docs/src/`: MkDocs sources (material theme); CI deploys on change.

ArgoCD bootstrap: `core/argocd/kustomization.yaml` (HA install + ksops patch + build opts `--enable-alpha-plugins --enable-exec`).

## Secrets (Critical)
- **Only** `*.enc.yaml` are committed. `secret*.yaml` and plain Talos `controlplane.yaml`/`worker.yaml` are gitignored (see .gitignore).
- Edit exclusively with `sops <file>.enc.yaml` (age keys defined in .sops.yaml for common secret fields).
- Kustomize decryption: `secret-generator.yaml` (kind: ksops) + `files: - secret.enc.yaml`. Requires `ksops` binary (exec'd) and `SOPS_AGE_KEY_FILE` pointing to age private key.
- Cluster: age key mounted as `argocd-age-key` secret; ArgoCD repo-server patched in `core/argocd/ksops.yaml` (init from viaductoss/ksops:v4.5.1).
- Local render of secret-containing dirs will fail without the key + ksops in PATH.

## Local Rendering & Validation
- `kubectl kustomize <dir>/ --enable-helm` (or `kustomize build --enable-helm --enable-alpha-plugins`).
- Helm charts are referenced inline (never committed; see **/charts/ in .gitignore); kustomize fetches at build time.
- Talos configs: `sops -d infra/*.enc.yaml > /tmp/talos-config.yaml` then feed to `talosctl`.
- Gitleaks runs on every PR/push (`.github/workflows/gitleaks.yaml` + .gitleaks.toml allowlist for .enc.yaml).

## Gotchas & Conventions
- Sync policy: mostly `prune: false`, `selfHeal: true`, `CreateNamespace=true`. Serverside dirs add `ServerSideApply=true`.
- Some docs/ references use stale paths (e.g. core-components/); trust the ApplicationSets in `core/argocd/` and live directory tree.
- Adding an app: create `apps/<name>/kustomization.yaml` (resources + optional generators), commit; ArgoCD discovers it.
- No Makefile / task runner / package.json; all ops are kubectl/kustomize/sops/talosctl/argocd CLI + git.
- Finalizer stuck? See `docs/src/Core components/argocd.md` for patch commands.
- Dependabot scans docker images under apps/core/operators weekly.
- HTTPRoutes on `*.menia.cc` (Gateway API) are LAN-only. Public internet exposure for apps is done exclusively via Cloudflare Tunnels (`core/cloudflared/` + per-app `cloudflared.yaml`). Never assume `*.menia.cc` hostnames are publicly reachable.

## Docs & CI
- MkDocs in `docs/`: `cd docs && pip install -r requirements.txt && mkdocs ...` (CI: `.github/workflows/docs.yaml`).
- Real operational notes live in `docs/src/` (WIP).

Source of truth = the YAML files + ApplicationSets, not prose.
