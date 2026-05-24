# ArgoCD

ArgoCD is the GitOps engine for the entire cluster. All Applications are created automatically via ApplicationSets (see `core/argocd/appset-*.yaml`).

## Bootstrap

The ArgoCD installation itself is defined in `core/argocd/kustomization.yaml` (HA mode + ksops plugin + custom build options).

Apply with:
```bash
kubectl kustomize core/argocd/ --enable-helm | kubectl apply -f -
```

## Access

**Important**: All HTTPRoutes on `*.menia.cc` (including the one for ArgoCD) are only reachable from the local LAN.

- **From the LAN**: https://argocd.menia.cc
- **From anywhere else**: Use port-forward:
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```

Public internet exposure for applications is done exclusively via Cloudflare Tunnels (see `core/cloudflared/` and per-app `cloudflared.yaml` resources). ArgoCD itself is not currently exposed publicly.

## SOPS / Age key

The repo-server needs the age private key to decrypt secrets at render time.

Create the secret:
```bash
cat <your_key_file> | kubectl create secret generic argocd-age-key --namespace=argocd \
  --from-file=key.txt=/dev/stdin
```

(See `core/argocd/ksops.yaml` and the age key secret for the full setup.)

## Stuck finalizers / cleanup

If ArgoCD or Applications are stuck in terminating state:

```bash
for app in $(kubectl get apps -n argocd -o name); do
  kubectl patch $app -p '{"metadata": {"finalizers": null}}' --type merge
done
```

## Further reading

- The ApplicationSets live in `core/argocd/`
