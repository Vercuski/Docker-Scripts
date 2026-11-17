# Airbyte
ELT platform with 600+ connectors: sync data from databases, SaaS APIs and files into warehouses, lakes and
databases, with incremental syncs, CDC, schema-change handling and a no-code connector builder.<br>
UI + API: http://localhost:8154 - password `Password123` (on the first visit enter your email and organisation)<br>

**Runs on Kubernetes, not Compose.** Airbyte dropped Docker Compose deployments with v1.0 (2024); the only supported
installs are `abctl` (which creates its own kind cluster) and the Helm chart. This stack uses the Helm chart on the
**Orchestration/K3s** cluster that's already in the repo, so Airbyte reaches the other stacks like everything else.

| Service | What it does |
|---|---|
| `airbyte-db-init` | Creates role + database `airbyte` in the PostgreSQL stack (role has CREATEDB: Airbyte's Temporal creates `temporal` and `temporal_visibility`) |
| `airbyte-install` | `helm upgrade --install airbyte` (chart `AIRBYTE_CHART_VERSION`) into namespace `airbyte`, using `values.yaml`; waits up to 30 min |
| `airbyte-proxy` | socat: `localhost:8154` -> NodePort 30081 on the k3s node |

**Start order:** `Databases/PostgreSQL`, then `Orchestration/K3s` (wait for `k3s-setup` to finish), then this stack.
The first install pulls several GB of images into K3s and takes 10-20 minutes: follow it with
`docker logs -f airbyte-install` or Headlamp (namespace `airbyte`). Re-running `docker compose up -d airbyte-install`
is safe and also upgrades after you change the chart version or `values.yaml`.

Pods resolve `postgresql` through the K3s stack's CoreDNS zones (`K3S_GROUPNETWORK_HOSTS`); add other stacks you
want as sources/destinations there (e.g. `mssqldb`, `clickhouse`) and restart `k3s-setup`. Logs and state go to the
chart's own MinIO pod inside K3s.

Resources: plan for about 4 GB of RAM for Airbyte's pods plus K3s itself; give Docker Desktop at least 8 GB.

Remove it: `docker exec k3s kubectl delete namespace airbyte` (the database stays in PostgreSQL).

API (bearer token from *Settings > Applications*):
```sh
curl -H "Authorization: Bearer <token>" http://localhost:8154/api/public/v1/workspaces
```

https://docs.airbyte.com/platform/deploying-airbyte/
