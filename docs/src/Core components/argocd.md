# ArgoCD

## Access

Reach ArgoCD using kubectl proxy feature:
`kubectl port-forward svc/argocd-server -n argocd 8080:443`

To push your sops private key, use:
```bash
cat <your_key_file> | kubectl create secret generic sops-age --namespace=argocd \
--from-file=key.txt=/dev/stdin
```