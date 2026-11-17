# Headlamp
Kubernetes web UI: workloads, logs, exec into pods, YAML editing, Helm releases, events and a plugin system.
The Kubernetes project recommends it as the replacement for the archived Kubernetes Dashboard.<br>
UI: http://localhost:4466<br>
<br>
Reads `kubeconfig-groupnetwork.yaml` from the **K3s** stack's kubeconfig folder (written by `k3s-setup`), so start
Orchestration/K3s first. No login: Headlamp uses that kubeconfig's admin certificate - local use only.<br>
To browse a different cluster, put its kubeconfig in that folder and set `HEADLAMP_KUBECONFIG` to the file name (the
server address must be reachable from a container: `host.docker.internal` instead of `127.0.0.1`/`localhost`).
Headlamp also ships as a desktop app that uses your normal `~/.kube/config`.

https://headlamp.dev/docs/latest/
