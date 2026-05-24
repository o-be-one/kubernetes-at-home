# Encryption

This cluster uses **Mozilla SOPS** with **age** keys + **KSOPS** (kustomize-sops) to manage all secrets declaratively.

## Why this approach

- All sensitive data lives in git (encrypted).
- No plain-text secrets ever committed.
- ArgoCD (and local `kustomize`) can decrypt on the fly during rendering.

## File naming & rules (strict)

- Only `*.enc.yaml` files are tracked in git.
- Plain `secret*.yaml` and Talos `controlplane.yaml` / `worker.yaml` are **gitignored**.
- Generators that decrypt at build time are named `secret-generator.yaml` (kind: `ksops`).

See `.gitignore` and `.sops.yaml` for the full rules.

## How to edit secrets

Always edit the encrypted file directly:

```bash
sops path/to/secret.enc.yaml
```

SOPS will decrypt in your editor, let you modify, then re-encrypt on save.

The age recipients are defined in `.sops.yaml`.

## How decryption works in Kustomize

Every component that needs secrets has two files:

1. `secret.enc.yaml` — the encrypted data
2. `secret-generator.yaml` — a small KSOPS resource, e.g.:

```yaml
apiVersion: viaduct.ai/v1
kind: ksops
metadata:
  name: my-secret-generator
  annotations:
    config.kubernetes.io/function: |
        exec:
          path: ksops
files:
  - secret.enc.yaml
```

When you run `kubectl kustomize ... --enable-alpha-plugins`, KSOPS (the binary) is invoked and injects the decrypted data.

## In the cluster (ArgoCD)

The repo-server is patched (`core/argocd/ksops.yaml`) to:
- Side-load the `ksops` and `kustomize` binaries from `viaductoss/ksops:v4.5.1`
- Mount the age private key as `argocd-age-key` secret at `SOPS_AGE_KEY_FILE`

## Locally (for validation / rendering)

You need:
- `sops` installed
- `ksops` binary in `$PATH`
- `SOPS_AGE_KEY_FILE` pointing to your age private key

Then the normal command works:

```bash
kubectl kustomize <component-dir>/ --enable-helm
```

You need `ksops` in your PATH and the environment variable `SOPS_AGE_KEY_FILE` pointing to your private age key for any secret generators to work.

## Talos machine configs

The full control plane and worker configs (including all secrets) are also stored encrypted:

- `infra/controlplane.enc.yaml`
- `infra/worker.enc.yaml`
- `infra/secrets.enc.yaml`

Decrypt them with `sops -d` when you need to feed them to `talosctl`.

## Summary of the critical rule

**Never** commit a plain `secret*.yaml` or decrypted Talos config.  
**Always** edit via `sops *.enc.yaml`.

This is enforced by gitleaks in CI and by the project's `.gitignore`.
