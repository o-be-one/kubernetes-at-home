# ArgoCD

## Access

Reach ArgoCD using kubectl proxy feature:
`kubectl port-forward svc/argocd-server -n argocd 8080:443`

To push your sops private key, use:
```bash
cat <your_key_file> | kubectl create secret generic sops-age --namespace=argocd \
--from-file=key.txt=/dev/stdin
```

## Deleting ArgoCD and all applications

If ArgoCD is stuck in terminating state, you can try to remove finalizers from all applications:

```bash
for app in $(kubectl get apps -n argocd -o name); do
  kubectl patch $app -p '{"metadata": {"finalizers": null}}' --type merge
done
```