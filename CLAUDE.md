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
- Authentik, Zitadel and Ory (Kratos + Hydra) → PostgreSQL stack; their one-shot `*-db-init` containers create their databases. Authentik, Authelia and Kratos send mail to Mailpit
- Authelia forward-auth → Nginx Proxy Manager, which mounts the nginx snippets in `RP-LB/NginxProxyManager/snippets` at `/snippets`
- Azure Service Bus emulator, Hangfire → MSSQL stack (`mssqldb`)
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
- Grafana provisions Prometheus, Tempo, Loki and InfluxDB data sources from `Visualization/Grafana/provisioning/datasources/datasources.yaml`
- HAProxy round-robins to the Nginx and Apache web server stacks
- Trino → PostgreSQL, MSSQL, MySQL, MongoDB, ClickHouse and Cassandra stacks, one catalog each in `Analytics/Trino/etc/catalog` (credentials in Trino's `.env` must match those stacks; Trino starts even when they are down)
- JupyterLab → Apache Spark (both define the same `spark_data` bind volume and the notebook runs as UID 185) and Trino
- Apache Flink → Kafka (`kafka:29092`) for streaming jobs; connector JARs go in the Flink `jobs` volume

## Verifying changes

Validation used in this repo: run `docker compose config` on every stack, check for duplicate IPs / host ports / aliases / container names across all compose files, confirm every bind path exists in `CreateVolumes`, and confirm `.env` values equal the compose defaults.
