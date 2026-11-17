# K3s + Argo CD
A single-node Kubernetes cluster (K3s) running as a container on GroupNetwork, with Argo CD installed into it.

| | |
|---|---|
| Kubernetes API | `https://localhost:6443` (from containers: `https://k3s:6443`) |
| kubeconfig (host) | `<ROOT_VOLUME_DIR>/docker/volumes/Orchestration/K3s/kubeconfig/kubeconfig.yaml` |
| kubeconfig (containers) | same folder, `kubeconfig-groupnetwork.yaml` (used by Orchestration/Headlamp) |
| Argo CD | http://localhost:8124 - `admin` / `Password123` |

```powershell
$env:KUBECONFIG = "D:\docker\volumes\Orchestration\K3s\kubeconfig\kubeconfig.yaml"
kubectl get nodes
```

## What `k3s-setup` does (on every `docker compose up`, safe to repeat)
1. Writes `kubeconfig-groupnetwork.yaml` (server `https://k3s:6443`) next to K3s' own kubeconfig.
2. Lets pods resolve GroupNetwork services by name: pods cannot use Docker's DNS, so each `name=IP` in
   `K3S_GROUPNETWORK_HOSTS` becomes a CoreDNS zone (ConfigMap `kube-system/coredns-custom`). Add entries there for
   other stacks your workloads need.
3. Installs or upgrades Argo CD `ARGOCD_VERSION` from the official install manifest, switches the UI to plain HTTP on
   NodePort 30080 (published as host port 8124) and sets the admin password.

## Argo CD with the Gitea stack
In Argo CD: *Settings → Repositories → Connect repo* with URL `http://gitea:3000/<owner>/<repo>.git` (and a Gitea
token for private repos), then create an Application pointing at a folder of manifests or a Helm chart.

## Notes
- Traefik is disabled (ports 80/443 belong to Nginx Proxy Manager). Workloads are reached through NodePort
  services; publish extra NodePorts by adding them to the `k3s` service's `ports`.
- Needs a cgroup v2 Docker host (Docker Desktop with WSL2 is). Kubernetes 1.35+ refuses to run on cgroup v1.
- `docker compose down` keeps the cluster (state is in the `server` volume folder); empty that folder to start over.

https://docs.k3s.io/ · https://argo-cd.readthedocs.io/
