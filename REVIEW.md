# Docker-Scripts review — September 2026

All 36 `docker-compose.yml` files now pass `docker compose config` (Compose v2.39.4). They also pass a repo-wide check for duplicate IPs, host ports, network aliases and container names, and for volume paths that are missing from `CreateVolumes`. Before these changes, 3 files failed to parse or validate. There were also 2 IP collisions, 7 host-port collisions, 1 alias collision and about a dozen volume/path mismatches.

Your uncommitted work in progress (Seq, MSSQL, SuperTokens, README) was kept and built on.

## Stacks that could not start before

| Stack | Problem | Fix |
|---|---|---|
| Containerization/DockerRegistry | `container_name` defined twice (YAML error). UI proxied to `localhost:5000`, which is the UI's own container. UI was not on GroupNetwork. Volume path `Containerization/Registry` did not match `CreateVolumes`. CORS header name was wrong. | Single name. UI on the network (.181) and proxying to `dockerregistry:5000`. Path fixed. Unneeded CORS headers removed. Pinned `registry:3`. |
| Search/OpenSearch | `OPENSEARCH_HOSTS` value was invalid YAML (nested double quotes). No `.env`, so `ROOT_VOLUME_DIR` was undefined. No `OPENSEARCH_INITIAL_ADMIN_PASSWORD`, which is required since 2.12. IPs .154/.155 collided with Filebeat/Logstash. Ports 9200/5601 collided with Elastic. | Quoting fixed. `.env` added with a strong dev password. IPs moved to .156–.158. Host ports changed to 9201/9601/5602. |
| Scheduling/Hangfire | `depends_on: sqlserver` pointed to a service that doesn't exist (invalid project). `Server=localhost` pointed at the app's own container. Port 5000 collided with the Registry. | Changed to `Server=mssqldb`, port 5010, `aspnet:${DOTNET_VERSION:-10.0}`. README explains that this hosts *your* published app. |
| Messaging/Kafka | `cp-kafka:latest` is now Confluent 8.x / Kafka 4.x, which removed ZooKeeper. The Kafka and ZooKeeper **aliases were swapped**. Both advertised listeners used `localhost`, so other containers could not connect. `KAFKA_OFFSETS.TOPIC...` was not a valid env name. Kafka-UI was not on the network and had no cluster configured. | Rewritten as a single-node **KRaft** broker on `apache/kafka:4.1.0`. Listeners are `kafka:29092` (containers) and `localhost:9092` (host). Switched to `kafbat/kafka-ui` (the maintained fork), configured, on port 8084. ZooKeeper removed. **Empty the old Kafka data folder before first start.** |
| Databases/Prometheus | The mounted `prometheus.yml` was never created, so Docker created a directory in its place and Prometheus would not start. Alertmanager's config was also missing. Node-exporter read empty bind folders instead of the host. It used a flag removed in newer versions (`ignored-mount-points`). Alertmanager had the alias `prometheus`. | `prometheus.yml` and `alertmanager.yml` added to the repo. Node-exporter now reads the host's `/proc`, `/sys` and `/`. Aliases fixed. Unused volumes removed. |
| RP-LB/HAProxy | An empty bind folder over `/usr/local/etc/haproxy` meant there was no `haproxy.cfg`, so the container exited. | `haproxy.cfg` added: port 8100 round-robins to nginx/apache, and stats are on 8404. |
| IaC/Terraform | The Terraform CLI exits immediately, so `restart: unless-stopped` put it in a restart loop. `TZ=America/Eastern` is not a valid time zone. Gaia's Mongo was not on GroupNetwork, so Gaia could not reach it. The runner mounted a data folder as `docker.sock`. | Terraform container kept alive (`docker exec terraform terraform …`). Mongo is on the network as `gaia-mongo` and persists to the Terraform data volume. The runner gets the real Docker socket. Gaia moved to 8085. |
| Databases/Oracle | Both volumes were named `oracle-data`. The healthcheck used the wrong password and a `.sql` file that doesn't exist. | Volume renamed to `oracle-backup`. Healthcheck now uses the image's `checkDBStatus.sh`. |
| Visualization/Grafana | Volume path typo `Visualiztion`, so the bind failed. | Fixed. |
| WebServers/Nginx | Volume paths (`Nginx-UI`, `Nginx/...`) did not match `CreateVolumes` (`WebServers/...`). Port 80 collided with Nginx Proxy Manager, and 8080 collided with CockroachDB. | Paths fixed. Typo'd volume names (`rabbinginx_ui`, `nginix_www`) cleaned up. Ports changed to 8180/8181. |
| EventStore / phpMyAdmin | Both used IP .20, so whichever started second failed. | EventStore moved to .21 (the README already said .21). |
| Portainer / Rancher | Both used IP .91. Portainer's 9100 collided with node-exporter and MinIO. Rancher's 80/443 collided with Nginx Proxy Manager. | Portainer moved to .92 and port 9010. Rancher moved to ports 8480/8444. |

## Silent data or behavior bugs

- **SonarQube**: the volumes were mounted at `/opt/SonarQube/...`, but Linux paths are case-sensitive and the real path is `/opt/sonarqube`. **Nothing was ever persisted.** It also connected as `sa` instead of the `sonarqube` login your SQL scripts create.
- **ClickHouse**: logs went to `/var/lib/clickhouse-server`; the real log path is `/var/log/clickhouse-server`. Native port 9000 collided with SonarQube, so it's now 19000.
- **RabbitMQ**: without a fixed `hostname`, each re-created container got a new node name, and existing data under the old name was ignored. Now set to `hostname: rabbitmq`.
- **InfluxDB**: `influxdb:latest` now points to InfluxDB 3 Core, which ignores every `DOCKER_INFLUXDB_INIT_*` variable. Pinned to `influxdb:2`.
- **mongo-express**: it was using the wrong env variables for the root login. It now uses `ME_CONFIG_MONGODB_URL`.
- **MariaDB vs MySQL**: both, plus Adminer, used the alias `mysqldb`, so DNS round-robined between different servers. MariaDB is now `mariadb` (host port 3307), and Adminer is `adminer`.
- **Neo4j**: `NEO4JLABS_PLUGINS` was removed in Neo4j 5, so APOC was never installed. It's now `NEO4J_PLUGINS`. The README showed the wrong initial password.
- **Elasticsearch**: the one-shot `setup` container had `restart: unless-stopped`, so it restarted forever. It's now `restart: "no"`.
- **Apache Spark**: the official image has no default server process, so a command was added to start the master. `build: .` pointed at a Dockerfile that doesn't exist. UI port 9090 collided with Prometheus, so it's now 8090. A worker was added (.192) so jobs can actually run.
- **Seq**: your WIP default port 8081 collided with MediaWiki. It's back to 8089.
- **MSSQL**: `MSSQL_AGENT_ENABLED: 1` changed to `"true"`.
- **PostgreSQL**: `container_name: posgresql` typo fixed. Pinned to `postgres:18`. A floating `latest` would jump major versions, and that requires `pg_upgrade`.
- **CockroachDB**: noted that `COCKROACH_PASSWORD` is ignored in `--insecure` mode.
- **Backstage**: `POSTGRES_PORT` added (the production app-config needs it). README build steps fixed (`yarn install --immutable`, no bogus `--config` path).
- **Nginx Proxy Manager**: backslash volume paths changed to `/`. Added `container_name`.

## Scripts and repo hygiene

- `CreateVolumes.bat` created every **Databases** folder on **C:** while all `.env` files point to **D:**. Fixed.
- `CreateVolumes.sh` and `CreateNetwork.sh` were saved with CRLF line endings and had no shebang, so bash fails with `$'\r'`. Converted to LF with `#!/usr/bin/env bash`. `CreateVolumes.sh` also honors `ROOT_VOLUME_DIR`. A new `.gitattributes` keeps `*.sh` files LF.
- Dropped folders nothing uses any more: ZooKeeper, Kafka secrets, node-exporter proc/sys, HAProxy, SuperTokens.
- `ClickHouse/.env` and `Milvus/.env` used `$HOME`. Changed to `D:` to match the rest.
- `Orchestration/Kubernetes/notes.txt` had a **service-account JWT committed to a public repo**. It expired in 2023, but it was removed and replaced with a warning. Consider rewriting git history if you care about it.
- Obsolete `version:` keys removed. `restart: unless-stopped` added to every long-running service. Copy-paste service names cleaned up (`client` changed to `haproxy`/`nginx`).
- ProGet README (it was a copy of the RabbitMQ one) and README IP tables corrected. Added a "Getting started" section.

## Flagged but not changed (your call)

1. **EventStoreDB** `20.10.2-buster-slim` is from 2021. The product is now **KurrentDB** (`kurrentplatform/kurrentdb`), with `KURRENTDB_*` env vars. External TCP was removed in v24, so it needs client changes.
2. **Elastic** `STACK_VERSION=8.7.1` is very old. Bump to the latest 8.x or 9.x.
3. **ProGet** `24.0.2` is old. The `SSL_CERT_FILE`/`https://*:443` settings should be checked against Inedo's current Docker HTTPS docs, or you could terminate TLS in Nginx Proxy Manager instead.
4. **PostgreSQL**: if your existing data folder was created by PG 17 or earlier, pin that major version instead of 18, or migrate with `pg_upgrade`.
5. **SuperTokens** `supertokens-postgresql:9.3` is behind current releases. It also needs a `supertokens` database created in Postgres.
6. **Kubernetes Dashboard** is archived. Headlamp is the recommended replacement.
7. **Gaia** (Terraform UI) is unmaintained. Consider replacing it (see below).
8. Old Docker volumes with renamed names (`rabbinginx_ui`, `nginix_www`, `nginx`, `haproxy`, `zookeeper_*`, `kafka_secrets`, `node_exporter_*`, `prometheus`) can be removed with `docker volume rm`.

## Host port map (after the changes)

80/81/443 NPM · 1113/2113 EventStore · 1433 MSSQL · 1521 Oracle · 3000 Grafana · 3306 MySQL · 3307 MariaDB · 3567 SuperTokens · 5000/5001 Registry/UI · 5010 Hangfire · 5050 pgAdmin · 5341/8089 Seq · 5432 Postgres · 5601 Kibana · 5602 OpenSearch Dashboards · 5672/15672/15692 RabbitMQ · 6379 Redis · 7007 Backstage · 7077/8090 Spark · 7473/7474/7687 Neo4j · 8080/26257 CockroachDB · 8081 MediaWiki · 8082 phpMyAdmin · 8083 Apache · 8084 Kafka UI · 8085 Gaia · 8086 InfluxDB · 8087 Adminer · 8088 mongo-express · 8091/8092 ProGet · 8100/8404 HAProxy · 8123/19000 ClickHouse · 8180/8181/8443 Nginx/Nginx UI · 8480/8444 Rancher · 9000 SonarQube · 9010/9443 Portainer · 9042 Cassandra · 9090 Prometheus · 9091/19530 Milvus · 9092 Kafka · 9093 Alertmanager · 9100 node-exporter · 9110/9111 MinIO (Milvus) · 9200 Elasticsearch · 9201/9601 OpenSearch · 27017 MongoDB

## Suggested new stacks

These are ordered by how much they would help a .NET/ASP.NET Core developer.

| Priority | Software | Category | Why |
|---|---|---|---|
| 1 | **.NET Aspire Dashboard** (`mcr.microsoft.com/dotnet/aspire-dashboard`) | Observability | A standalone OTLP receiver with traces, metrics and structured logs for any .NET app. It needs zero config and pairs with Seq. |
| 2 | **OpenTelemetry Collector + Grafana Tempo + Loki** | Observability | Completes the Grafana/Prometheus stack with traces and logs, so you have one pipeline for every app. |
| 3 | **Keycloak** | Authentication | A full OIDC/OAuth2 provider for testing ASP.NET Core `AddJwtBearer`/`AddOpenIdConnect` locally. It complements SuperTokens. |
| 4 | **Azurite + Azure Service Bus emulator + Cosmos DB emulator** | Cloud emulators | Local Blob/Queue/Table storage, Service Bus and Cosmos for Azure-targeted .NET code. The Service Bus emulator can reuse your MSSQL. |
| 5 | **Mailpit** | Dev tooling | Catches SMTP mail and shows it in a web UI, for testing email flows. |
| 6 | **HashiCorp Vault** (or OpenBao) | Secrets | Secret storage for local config and the `VaultSharp` provider. It's also useful with Terraform. |
| 7 | **Gitea / Forgejo + Actions runner** | CI/CD | A self-hosted git server with a GitHub-Actions-compatible CI to test pipelines locally. |
| 8 | **Harbor** (or add **Trivy**) | Containerization | A registry with vulnerability scanning, RBAC and replication. It's an upgrade over the bare registry. |
| 9 | **Unleash** or **Flagsmith** | Feature flags | Works with `Microsoft.FeatureManagement` through OpenFeature providers. |
| 10 | **Garnet** (Microsoft) or **Valkey** | Cache | Garnet is Microsoft Research's Redis-protocol-compatible cache written in .NET. Valkey is the open-source Redis fork. |
| 11 | **Qdrant** or the **pgvector** Postgres image | Vector DB | A lighter alternative to the 3-container Milvus stack for Semantic Kernel / RAG work. |
| 12 | **Debezium + Kafka Connect** | Messaging/CDC | Change-data-capture from MSSQL/Postgres into your new KRaft Kafka. |
| 13 | **Dozzle** + **Uptime Kuma** | Ops | A real-time container log viewer and an uptime/health dashboard for all these stacks. |
| 14 | **Headlamp** | Orchestration | Replaces the archived Kubernetes Dashboard. |
| 15 | **WireMock** | Testing | Stubs HTTP APIs for integration tests. It's also available as a Testcontainers module. |
| 16 | **Atlantis** or **Terrakube** | IaC | Actively maintained alternatives to Gaia for running Terraform from a UI or PR workflow. |

A useful repo-level addition would be a root `compose.yaml` that pulls each stack in with `include:`. With profiles on it (e.g. `docker compose --profile observability up`), you could bring up related stacks together.

## Follow-up: settings moved to .env (2026-09-27)

Every stack's `.env` now holds the settable values: image tags, host ports, static IPs, credentials/database names and tuning knobs (heap sizes, ulimits, log rotation, worker cores/memory, time zones). The compose files reference them as `${VAR:-default}`, and each default is exactly the previous hard-coded value.

This was verified with `docker compose config` on all 36 stacks. The resolved output is byte-identical to the pre-refactor snapshot, both with the new `.env` files and with an `.env` containing only `ROOT_VOLUME_DIR`, so every default matches its `.env` value. The single intentional difference is that RabbitMQ now sets `RABBITMQ_DEFAULT_USER`/`RABBITMQ_DEFAULT_PASS` explicitly, defaulting to the image's own `guest/guest`.

Notes:
- `ROOT_VOLUME_DIR` keeps `:?error`: a missing root would bind volumes to the wrong place, so failing is safer than a default.
- Kafka's advertised `EXTERNAL` listener follows `KAFKA_PORT`, so changing the host port keeps clients working.
- The existing `.env` values for Seq, Elastic, OpenSearch and Hangfire were preserved under "Stack settings". The OpenSearch and Seq passwords switched from `:?` (required) to `:-` defaults, matching the rest of the repo.
- Milvus: changing `MILVUS_MINIO_ACCESS_KEY/SECRET_KEY` also requires changing Milvus's `milvus.yaml`. Milvus expects `minioadmin` by default.
