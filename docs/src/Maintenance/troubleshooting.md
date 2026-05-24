# Troubleshooting

## Web returning 404

- Ensure Cilium is running
- If you have uninstalled and reinstalled Cilium, it removes all HTTPRoutes — re-apply `infra/cilium/`

## Network issues

- Check Cilium pods: `kubectl get pods -n kube-system | grep cilium`
- Run connectivity test:
  ```bash
  cilium connectivity test
  ```
  (requires the privileged namespace from `infra/cilium/namespace.yaml`)

## ArgoCD finalizers stuck

If Applications or ArgoCD itself won't delete:

```bash
for app in $(kubectl get apps -n argocd -o name); do
  kubectl patch $app -p '{"metadata": {"finalizers": null}}' --type merge
done
```

See also [ArgoCD](../Core components/argocd.md).

## Secret decryption problems

- Make sure your age key is in the `argocd-age-key` secret
- Locally: ensure `SOPS_AGE_KEY_FILE` is set and `ksops` is in PATH
- Never commit plain `secret*.yaml` — only edit `*.enc.yaml` with `sops`
