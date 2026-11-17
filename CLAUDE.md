# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of independent Docker Compose stacks for a local development environment (mostly aimed at .NET work). There is no build or test suite; each stack is `<Category>/<Tool>/` containing `docker-compose.yml`, `.env`, `ReadMe.md`, and any mounted config files (e.g. `prometheus.yml`, `haproxy.cfg`, `vault.hcl`). `REVIEW.md` records past audit findings, the host-port map, and open "flagged but not changed" items.

## Commands

```sh
./CreateNetwork.sh    # or CreateNetwork.bat — creates external GroupNetwork (172.20.0.0/16), required by every stack
./CreateVolumes.sh    # or CreateVolumes.bat — creates the host folders behind bind-mounted volumes
cd <Category>/<Tool> && docker compose up -d
docker compose config # validate a stack and show fully resolved values (the main "test")
```

`.env` files Claude creates are delivered as `Claude outputs/<Tool>.env` (remote tools can't write `.env` files); `Claude outputs/Move-EnvFiles.ps1` moves them into `<Category>/<Tool>/.env`. Stack folder names are unique across categories, which that script relies on.

`ROOT_VOLUME_DIR` is the only host-specific value. It is **not** set in any `.env`; `CreateVolumes.bat` (default `D:`, saved with `setx`) or `CreateVolumes.sh` (default `$HOME`, saved to the shell rc file) sets it once per machine. Both accept an optional root argument. For ad-hoc validation: `ROOT_VOLUME_DIR=/tmp docker compose config`.

## Conventions that span multiple files

When adding or changing a stack, these must stay consistent across the repo:

- **Shared network**: every service joins the external `GroupNetwork` with a static `ipv4_address` and a network `aliases` entry used as its DNS name by other stacks. IP ranges are grouped by category; the authoritative IP table is in `README.md` — update it when adding services. IPs, host ports, aliases and `container_name`s must be unique across *all* stacks (see the host-port map in `REVIEW.md`).
- **`.env` holds every settable value**, grouped under the headers `Image versions`, `Host ports`, `Network (static IPs)`, `Credentials & settings`, `Tuning`. Compose references them as `${VAR:-default}` where the default is **identical** to the `.env` value, so a stack still works with an empty `.env` (plus `ROOT_VOLUME_DIR` in the environment). Each `.env` keeps a commented `# ROOT_VOLUME_DIR=D:` line for a per-stack override. Internal wiring (container-side ports, service DNS names, cert paths) stays hard-coded in compose.
- **Volumes** are named local volumes bound to `${ROOT_VOLUME_DIR:?run CreateVolumes.bat or CreateVolumes.sh first}/docker/volumes/<Category>/<Tool>/<sub>` (`:?` is intentional — no default). Any new path must be added to **both** `CreateVolumes.sh` (`mkdir -p`) and `CreateVolumes.bat` (`call :mk`), with identical case (Linux is case-sensitive). If the image runs as a fixed non-root UID and doesn't chown its own data dir, add the path to the `own` list in `CreateVolumes.sh`.
- Long-running services use `restart: unless-stopped`; one-shot setup containers use `restart: "no"`. No top-level `version:` key. Pin image major versions where a floating tag would break existing data (e.g. Postgres, InfluxDB).
- Line endings are enforced by `.gitattributes`: `*.sh` and `*.cfg` LF, `*.bat` CRLF.
- Credentials like `Password123` are intentional local-dev defaults.

## Cross-stack dependencies

Stacks talk to each other over `GroupNetwork` by alias, so some require another stack to be running:
- Keycloak and SuperTokens → PostgreSQL stack (their own databases must exist)
- Infisical → PostgreSQL stack (`infisical-db-init` creates its role/database) and Redis stack (`redis`, password from `INFISICAL_REDIS_PASSWORD`, DB 2); `infisical-init` bootstraps the admin
- Authentik, Zitadel and Ory (Kratos + Hydra) → PostgreSQL stack; their one-shot `*-db-init` containers create their databases. Authentik, Authelia and Kratos send mail to Mailpit
- Authelia forward-auth → Nginx Proxy Manager, which mounts the nginx snippets in `RP-LB/NginxProxyManager/snippets` at `/snippets`
- Azure Service Bus emulator, Hangfire → MSSQL stack (`mssqldb`)
- Temporal, Airflow, Rundeck and n8n → PostgreSQL stack (their `*-db-init` containers create roles and databases; `temporal-schema` creates/upgrades the Temporal schemas, `airflow-init` runs migrations and sets the admin, `n8n-init` creates the owner). Airflow's sample DAG calls `temporal-ui`; nothing else depends on another scheduler. Camunda 8 (Orchestration Cluster on file-based H2, admin from `.env` via `config/application.yaml` placeholders, unprotected API by default) and Node-RED (`settings.js` bcrypt-hashes the admin password from env at start) are standalone; the Workflow/Automation category was folded into Scheduling
- Azure Event Hubs emulator → Azurite stack (`azurite`) for checkpoints and metadata
- Dependency-Track and DefectDojo → PostgreSQL stack (their `*-db-init` containers create the databases); DefectDojo brings its own Valkey. Trivy (server) output feeds DefectDojo (`Trivy Scan` import) and Dependency-Track (CycloneDX SBOMs)
- Harbor → PostgreSQL stack (`harbor-db-init` creates a `harbor` role and database); its own services are prefixed `harbor-*` so generic names like `redis`/`registry` don't collide. Dozzle mounts the Docker socket read-only
- Floci and LocalStack mount the Docker socket and start sibling containers for Lambda, RDS and similar services; LocalStack needs `LOCALSTACK_AUTH_TOKEN` in its `.env`
- OpenTelemetry Collector → Tempo/Loki (same stack) and Prometheus (`Observability/Prometheus`, which scrapes `otel-collector:8889` and accepts remote-write from Tempo)
- CloudBeaver → PostgreSQL, TimescaleDB, MSSQL, MySQL, MariaDB and ClickHouse stacks (connections seeded from `Databases/CloudBeaver/initial-data-sources.conf` into an empty workspace)
- RavenDB and Couchbase publish host-reachable addresses (`localhost:<port>`) to their clients; clients on GroupNetwork use the alias (RavenDB also needs `DisableTopologyUpdates`)
- Wiki.js and Outline → PostgreSQL stack, BookStack → MariaDB stack (their `*-db-init` containers create the databases); BookStack and Outline send mail to Mailpit. Outline logs in through the Dex container in its own stack
- Atlantis → Gitea stack: `atlantis-init` creates the `atlantis` bot user and token with the Gitea admin login from its `.env`; Gitea's `webhook.ALLOWED_HOST_LIST` includes `private` so it can call `http://atlantis:4141/events`, and Atlantis rewrites Gitea's public clone URLs to `http://gitea:3000`. Semaphore → PostgreSQL stack (`semaphore-db-init`)
- Debezium → Kafka stack (`kafka:29092`) and, for its PostgreSQL connector, the PostgreSQL stack running with `wal_level=logical`. Apicurio → PostgreSQL stack (`apicurio-db-init`). Kafka UI lists the Debezium Connect cluster and uses Apicurio's ccompat API as schema registry (both optional). Redpanda, NATS, Mosquitto, Artemis and Pulsar are standalone
- Prometheus also scrapes cAdvisor (`cadvisor:8080`, Observability/cAdvisor). SigNoz → PostgreSQL stack (`signoz-db-init`); its own ClickHouse/keeper live in the SigNoz stack, and its collector only accepts OTLP after the first admin is created. Jaeger, Pyroscope, Uptime Kuma and otel-lgtm are standalone
- Headlamp stack reads the K3s stack's `kubeconfig-groupnetwork.yaml` (same host folder, mounted read-only). Pods in K3s reach GroupNetwork services through CoreDNS zones generated from `K3S_GROUPNETWORK_HOSTS` (name=IP, keep in step with the IP table), e.g. Argo CD → `http://gitea:3000`. Nomad mounts `/var/run/docker.sock` and a fixed Docker-host path (`NOMAD_DATA_DIR`, deliberately not under `ROOT_VOLUME_DIR`)
- Nexus, BaGetter and Verdaccio are standalone (their nuget.org / npmjs.org proxies need internet). `nexus-init` accepts the Nexus CE EULA only when `NEXUS_ACCEPT_EULA=true`
- Meilisearch, Typesense and Solr are standalone (no other stack needed); Typesense is on host port 8137 because Couchbase owns 8108
- Graylog is self-contained (own MongoDB 8.0: Graylog 7.2 supports MongoDB 7.x-8.3.x, while `Databases/MongoDB` floats on `latest` = 9.x). `GRAYLOG_SELFSIGNED_STARTUP` replaces the preflight wizard
- Forgejo, GitLab and OneDev are standalone. Forgejo mirrors the Gitea stack (runner + jobs on `GroupNetwork` via the Docker socket) but needs no installer: `forgejo-init` creates the admin and a runner registration token. GitLab and ZAP listen on their host port numbers inside the container (GitLab `external_url`)
- Metabase, Superset and Redash → PostgreSQL stack (`*-db-init` creates each role/database); Redash also → Redis stack (DB 3). Superset builds `superset-drivers` from `Visualization/Superset/image` (the official image has no DB drivers)
- Grafana provisions Prometheus, Tempo, Loki, Pyroscope and InfluxDB data sources from `Visualization/Grafana/provisioning/datasources/datasources.yaml`
- HAProxy, Traefik (`/web` file route), Caddy, YARP (`/web`), Envoy and Kong (`/web`) all round-robin to the Nginx and Apache web server stacks; Traefik also routes any container labelled `traefik.enable=true` (Docker socket mounted read-only). YARP is built from `RP-LB/Yarp/src` (no stable official image)
- Trino → PostgreSQL, MSSQL, MySQL, MongoDB, ClickHouse and Cassandra stacks, one catalog each in `Analytics/Trino/etc/catalog` (credentials in Trino's `.env` must match those stacks; Trino starts even when they are down)
- JupyterLab → Apache Spark (both define the same `spark_data` bind volume and the notebook runs as UID 185) and Trino
- Apache Flink → Kafka (`kafka:29092`) for streaming jobs; connector JARs go in the Flink `jobs` volume
- Woodpecker → Gitea stack: `woodpecker-init` creates the `Woodpecker` OAuth2 app with the Gitea admin login from its `.env` and stores client id/secret in the data volume (the `-alpine` server image reads them in its entrypoint); Gitea webhooks go to `http://woodpecker-server:8000`, the browser OAuth redirect to `localhost:3001`. Jenkins (built `jenkins-plugins` image, JCasC in `casc/`) registers `http://gitea:3000`. Jenkins, the TeamCity agent and the Woodpecker agent mount the Docker socket and run as root; TeamCity's license agreement and admin account are a manual first-visit step
- Unleash and Flagsmith → PostgreSQL stack (`*-db-init`). Unleash creates its admin and client/frontend/admin API tokens from `.env` on an empty DB; Flagsmith's server bootstraps admin/org/project and `flagsmith-init` (Django shell) sets the admin password and adds Development/Production environments. GrowthBook is self-contained (own MongoDB 8.0; `growthbook-init` calls `/auth/firsttime` and creates an SDK connection). flagd reads flags as code from `FeatureFlags/Flagd/flags`. Consul runs as a single persistent server; `consul-init` imports `kv/seed.json` while `config/` is empty
- ObjectStorage stacks are standalone S3 stores: RustFS (MinIO replacement - MinIO CE is source-only/archived; `rustfs-init` = AWS CLI bucket creation), SeaweedFS (`weed mini`, S3 admin identity from `AWS_ACCESS_KEY_ID/SECRET`, buckets via `-bucket`), Garage (`garage.toml` with IPv4 binds - `[::]` panics without IPv6; `garage-init` is a Python script using the v2 admin API for layout, key import and buckets; `garage-webui` alongside)
- Dapr (ServiceMesh) → Redis stack (state store + pub/sub, DB 4; password via the `secretstores.local.env` component reading `REDIS_PASSWORD` from the sidecar env) and, for tracing, OpenTelemetry (`otel-collector:4317`). `dapr-sidecar` serves an app on the host via `--app-channel-address host.docker.internal` (host-gateway mapped); scheduler data in its volume (UID 65532). Consul for the ServiceMesh category lives in FeatureFlags/Consul
- AI stacks: Open WebUI → Ollama (`ollama:11434`; admin from `WEBUI_ADMIN_*` on first start, RAG embeddings via Ollama). LiteLLM → PostgreSQL stack (`litellm-db-init`), Ollama for local models, Langfuse via the `langfuse_otel` callback (v4 rejects the legacy ingestion API). Langfuse v4 → PostgreSQL (`langfuse-db-init`), Redis (DB 5), ObjectStorage/RustFS (`langfuse-s3-init` creates bucket `langfuse`) and its own ClickHouse 26.3; `LANGFUSE_INIT_*` create admin/org/project/keys `pk-lf-local-dev`/`sk-lf-local-dev`. Ollama GPU support is an overlay file (`docker-compose.gpu.yml`)
- Airbyte (DataIntegration) → Orchestration/K3s + PostgreSQL stack: Airbyte has no Compose deployment any more, so `airbyte-install` (alpine/helm) installs the Helm chart into K3s with the K3s kubeconfig folder mounted read-only (like Headlamp), `airbyte-db-init` creates the DB (role with CREATEDB for Temporal), and `airbyte-proxy` (socat) publishes localhost:8154 → `k3s:30081` (NodePort). Pods reach `postgresql` via `K3S_GROUPNETWORK_HOSTS`. NiFi is standalone (HTTPS only, 12+ char password, `nifi-init` seeds the conf volume)
- Mattermost and Plane (Collaboration) → PostgreSQL stack (`mattermost-db-init` / `plane-db-init`) and Mailpit; Plane also → Redis stack (DB 6) and brings its own RabbitMQ 3.13 (`plane-mq`: RabbitMQ 4.x in Messaging/RabbitMQ refuses Celery's transient control queues) and RustFS (`plane-minio`). `plane-proxy` uses `Collaboration/Plane/config/Caddyfile` (upstream routes pointed at `plane-*` aliases); `plane-init` creates the instance admin and clears the instance cache. `mattermost-init` creates the first user (= system admin) and team. Rocket.Chat is self-contained (own MongoDB 8.0 single-node replica set `rs0`) and mails to Mailpit
- DevTools are all standalone. Homepage (`DevTools/Homepage/config/*.yaml` mounted read-only; `services.yaml` was generated from Home.html's overview table and its `container:` entries must match `container_name`s) and Homarr mount the Docker socket read-only; `homarr-init` uses the Homarr CLI plus SQLite to create the admin and finish onboarding. code-server is built from `DevTools/CodeServer/image` (.NET SDK + Open VSX C# extension baked into `/opt/code-server/extensions`, copied into the `local` volume on start)
- Pact Broker and Hoppscotch → PostgreSQL stack (`*-db-init`); Hoppscotch also → Mailpit (`hoppscotch-init` completes onboarding: email magic-link sign-in via `mailpit:1025`; afterwards auth/SMTP settings live in its database, not env). k6's sample script and Toxiproxy's `wiremock` proxy target the WireMock stack; Toxiproxy's other proxies front `postgresql`, `mssqldb`, `redis` and `rabbitmq`. Microcks (uber image, in-memory) is re-seeded from `Testing/Microcks/artifacts` by `microcks-init` on every `up`

## Verifying changes

Validation used in this repo: run `docker compose config` on every stack, check for duplicate IPs / host ports / aliases / container names across all compose files, confirm every bind path exists in `CreateVolumes`, and confirm `.env` values equal the compose defaults.
