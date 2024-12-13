# Troubleshooting

## Web returning 404

- ensure Cilium is running
- if you have uninstalled Cilium and then reinstalled it, it removed all http routes you had configured

## Network issues

- check Cilium pods are healthy: `kubectl get pods -n kube-system | grep cilium`
- use `cilium connectivity test` to check reachability between nodes
  - this requires privileged namespace, deploy the one in `infra/cilium/namespace.yaml`