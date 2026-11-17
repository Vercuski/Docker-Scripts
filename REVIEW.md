# Docker-Scripts review — September 2026

All `docker-compose.yml` files (36 at the time of the review, 45 now) now pass `docker compose config` (Compose v2.39.4). They also pass a repo-wide check for duplicate IPs, host ports, network aliases and container names, and for volume paths that are missing from `CreateVolumes`. Before these changes, 3 files failed to parse or validate. There were also 2 IP collisions, 7 host-port collisions, 1 alias collision and about a dozen volume/path mismatches.

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

1. ~~**EventStoreDB**~~ *Done 2026-11-16: replaced by `Databases/KurrentDB`.* `20.10.2-buster-slim` is from 2021. The product is now **KurrentDB** (`kurrentplatform/kurrentdb`), with `KURRENTDB_*` env vars. External TCP was removed in v24, so it needs client changes.
2. ~~**Elastic**~~ *Done 2026-11-16: bumped to 9.5.6 (fresh data; see Search/ElasticSearch/ReadMe.md).* `STACK_VERSION=8.7.1` is very old. Bump to the latest 8.x or 9.x.
3. **ProGet** `24.0.2` is old. The `SSL_CERT_FILE`/`https://*:443` settings should be checked against Inedo's current Docker HTTPS docs, or you could terminate TLS in Nginx Proxy Manager instead.
4. **PostgreSQL**: if your existing data folder was created by PG 17 or earlier, pin that major version instead of 18, or migrate with `pg_upgrade`.
5. **SuperTokens** `supertokens-postgresql:9.3` is behind current releases. It also needs a `supertokens` database created in Postgres.
6. ~~**Kubernetes Dashboard**~~ *Done 2026-11-16: Orchestration/Headlamp added.* Kubernetes Dashboard is archived. Headlamp is the recommended replacement.
7. ~~**Gaia**~~ *Done 2026-11-16: removed; replaced by IaC/Atlantis and IaC/Semaphore.* Gaia (Terraform UI) was unmaintained.
8. Old Docker volumes with renamed names (`rabbinginx_ui`, `nginix_www`, `nginx`, `haproxy`, `zookeeper_*`, `kafka_secrets`, `node_exporter_*`, `prometheus`) can be removed with `docker volume rm`.
9. **MongoDB** stack uses `mongo:latest` and `mongo-express:latest`. `latest` is now MongoDB 9.0, which Graylog 7.2 doesn't support (it brings its own 8.0). Pin `MONGO_VERSION` to the major your data folder was created with (a 9.x data folder can't be opened by 8.x).

## Host port map (after the changes)

80/81/443 NPM · 2113 KurrentDB · 1433 MSSQL · 1521 Oracle · 3000 Grafana · 3306 MySQL · 3307 MariaDB · 3567 SuperTokens · 5000/5001 Registry/UI · 5010 Hangfire · 5050 pgAdmin · 5341/8089 Seq · 5432 Postgres · 5601 Kibana · 5602 OpenSearch Dashboards · 5672/15672/15692 RabbitMQ · 6379 Redis · 7007 Backstage · 7077/8090 Spark · 7473/7474/7687 Neo4j · 8080/26257 CockroachDB · 8081 MediaWiki · 8082 phpMyAdmin · 8083 Apache · 8084 Kafka UI · 8086 InfluxDB · 8087 Adminer · 8088 mongo-express · 8091/8092 ProGet · 8100/8404 HAProxy · 8123/19000 ClickHouse · 8180/8181/8443 Nginx/Nginx UI · 8480/8444 Rancher · 9000 SonarQube · 9010/9443 Portainer · 9042 Cassandra · 9090 Prometheus · 9091/19530 Milvus · 9092 Kafka · 9093 Alertmanager · 9100 node-exporter · 9110/9111 MinIO (Milvus) · 9200 Elasticsearch · 9201/9601 OpenSearch · 27017 MongoDB · 514/udp, 1514/1515, 55000 Wazuh manager · 5603 Wazuh dashboard · 9202 Wazuh indexer · 8093 Flink · 8094 Trino · 8888/4040 JupyterLab · 8290/8445 authentik · 8300/8301 ZITADEL · 9095 Authelia · 4433/4434 Kratos · 4444/4445 Hydra · 4455 Ory UI · 5674/9094/5301 Event Hubs emulator · 4566 Floci · 4567 LocalStack · 8095 Pub/Sub emulator · 8096 Firestore emulator · 9011/9020 Spanner emulator · 8446/8097 Lowkey Vault · 8098/8099 Dependency-Track API/UI · 4954 Trivy server · 8102 DefectDojo · 8103 Dozzle · 5002 zot · 8104 Harbor · 8105/38888 RavenDB · 6380 Garnet · 6381 Valkey · 11211 Memcached · 6333/6334 Qdrant · 5984 CouchDB · 8107-8110/11210 Couchbase · 9043/8106 ScyllaDB CQL/Alternator · 5433 TimescaleDB · 8978 CloudBeaver · 3003 Wiki.js · 6875 BookStack · 3002/5556 Outline/Dex · 8112 Structurizr · 8000 Kroki · 8111 draw.io · 8113/8114 Swagger UI/Redoc · 8115/2525/1143/1110 smtp4dev · 4141 Atlantis · 3004 Semaphore · 4222/8222 NATS · 1883/9002 Mosquitto · 61616/5675/61613/8161 Artemis · 19092/18081/18082/9644/8116 Redpanda · 6650/8117 Pulsar · 8118 Debezium · 8119/8120 Apicurio · 16686/14317/14318 Jaeger · 4041 Pyroscope · 3005 Uptime Kuma · 8121 cAdvisor · 3006/24317/24318 otel-lgtm · 8122/34317/34318 SigNoz · 6443 K3s API · 8124 Argo CD · 4466 Headlamp · 4646 Nomad · 8125 Nexus · 5555 BaGetter · 4873 Verdaccio · 8126/8127 Traefik · 8128/8134 Caddy · 8129 YARP · 8130/9902 Envoy · 8131/8132/8133 Kong · 7233/8135 Temporal · 8136 Airflow · 4440 Rundeck · 5678 n8n · 7700 Meilisearch · 8137 Typesense · 8983 Solr · 8202 OpenBao · 9003 step-ca · 8140/8139 ZAP proxy+API/UI · 8138 Infisical · 9004/12201/5140/5044 Graylog UI/GELF/Syslog/Beats · 3007/2223 Forgejo · 8141/2224 GitLab · 6610/6611 OneDev · 3008 Metabase · 8142 Superset · 8143 Redash

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
| 12 | ~~**Debezium + Kafka Connect**~~ *Done 2026-11-16 (Messaging/Debezium)* | Messaging/CDC | Change-data-capture from MSSQL/Postgres into your new KRaft Kafka. |
| 13 | ~~**Dozzle** + **Uptime Kuma**~~ *Done 2026-11-16* | Ops | A real-time container log viewer and an uptime/health dashboard for all these stacks. |
| 14 | ~~**Headlamp**~~ *Done 2026-11-16* | Orchestration | Replaces the archived Kubernetes Dashboard. |
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

## New stacks added (2026-09-27)

The top 7 suggestions were added as 9 stacks, because the Azure emulators are one stack each. They follow the repo conventions: one tool per folder, a static IP on GroupNetwork, bind-mounted volumes created by `CreateVolumes`, and every setting in `.env` as `${VAR:-default}`.

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| .NET Aspire Dashboard | Observability/AspireDashboard | .120 | 18888 UI, 18889 OTLP gRPC, 18890 OTLP HTTP | Anonymous by default. Telemetry is in memory only. |
| OpenTelemetry Collector | Observability/OpenTelemetry | .121 | 4317, 4318, 8889 (metrics), 13133 (health) | Traces go to Tempo, logs to Loki, metrics to Prometheus. |
| Grafana Tempo 3.0 | Observability/OpenTelemetry | .122 | 3200 | Monolithic mode. The metrics-generator remote-writes span metrics to Prometheus. |
| Grafana Loki 3.7 | Observability/OpenTelemetry | .123 | 3100 | Native OTLP ingestion, 7-day retention. |
| Keycloak | Authentication/Keycloak | .212 | 8280, 9001 (health/metrics) | `start-dev`, backed by the PostgreSQL stack (`keycloak` database). |
| Azurite | CloudEmulators/Azurite | .100 | 10000-10002 | Blob / Queue / Table. |
| Azure Service Bus emulator | CloudEmulators/AzureServiceBus | .101 | 5673 AMQP, 5300 | Uses the MSSQL stack. Entities are defined in `Config.json`. |
| Azure Cosmos DB emulator (vNext) | CloudEmulators/AzureCosmosDb | .102 | 8081, 1234 (Data Explorer) | HTTPS by default for the .NET SDK. |
| Mailpit | Email/Mailpit | .140 | 8025 UI, 1025 SMTP | Messages persisted in SQLite. |
| HashiCorp Vault | Security/Vault | .230 | 8200 | Server mode with file storage: needs init once, then unseal after each restart. |
| Gitea + Actions runner | SourceControl/Gitea | .225 / .226 | 3001 web, 2222 SSH | The runner registers itself with a shared token. Job containers join GroupNetwork. |

Changes to existing stacks to support these:
- **MediaWiki moved from 8081 to 8281.** The Cosmos DB Data Explorer always calls `localhost:8081` (upstream bug), so the emulator needs that port.
- **Prometheus** now has `--web.enable-remote-write-receiver` (for Tempo span metrics) and scrapes `otel-collector:8889`.
- **Grafana** now provisions Prometheus, Tempo, Loki and InfluxDB data sources, with trace-to-log links, from `provisioning/datasources/datasources.yaml`.

Verification:
- All 45 stacks pass `docker compose config`.
- There are no duplicate IPs, host ports, aliases or container names.
- `.env` values equal the compose defaults.
- These config files were checked with the real binaries: `otelcol-contrib validate`, `tempo -config.verify`, `loki -verify-config` and `promtool check config`.
- An end-to-end smoke test sent an OTLP trace, log and metric through the collector. They were readable in Tempo, Loki and the Prometheus exporter.
- Vault init/unseal/kv-v2 was tested against `vault.hcl`.
- Gitea 1.27 accepted the shared runner token and the runner registered with `runner-config.yaml`.
- Mailpit started with the configured settings.
- All image tags were confirmed to exist in their registries.

## New stack added (2026-10-07): SIEM/Wazuh

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Wazuh 4.14.8 (manager, indexer, dashboard) | SIEM/Wazuh | .240 certs (one-shot), .241 manager, .242 indexer, .243 dashboard | 5603 dashboard (HTTPS), 9202 indexer, 1514/1515 agents, 514/udp syslog, 55000 API | Based on upstream `wazuh-docker` v4.14.8 single-node. The cert generator runs once inside the stack and skips when certificates exist. Default credentials are the Wazuh defaults (indexer passwords are bcrypt hashes in `config/internal_users.yml`). |

Differences from upstream: certificates live in a bind volume (`SIEM/Wazuh/certs`) mounted as a folder instead of per-file mounts; `wazuh.yml` for the dashboard is generated from `.env` rather than mounted; the dashboard moved off 443 (Nginx Proxy Manager) and the indexer off 9200 (Elasticsearch); `restart: unless-stopped` instead of `always`; the indexer has a healthcheck that gates the manager and dashboard.

Verification: `docker compose config` passes; the full stack was started from empty volumes (cert generation, indexer green, Filebeat TLS to the indexer, API login, dashboard login and stored-API check, alerts indexed), then `down`/`up` again to confirm persistence and the cert-skip path. All image tags were pulled successfully.

## OS-agnostic volumes (2026-11)

Goal: every stack runs unchanged on Windows (Docker Desktop) and native Linux/macOS.

- `ROOT_VOLUME_DIR=D:` removed from all 44 `.env` files (left as a commented per-stack override). It is now a per-machine environment variable set by the `CreateVolumes` scripts, so no file in the repo hard-codes a Windows drive.
- `CreateVolumes.bat`: optional root argument (default `%ROOT_VOLUME_DIR%`, then `D:`), skips folders that already exist, saves `ROOT_VOLUME_DIR` with `setx` using forward slashes (`D:` resolves to `D:/docker/volumes/...` exactly as before).
- `CreateVolumes.sh`: optional root argument (default `$ROOT_VOLUME_DIR`, then `$HOME`), saves an idempotent `export` block to `~/.bashrc` / `~/.zshenv` / `~/.profile`, and on native Linux chowns the folders of images that run as a fixed non-root UID (Docker Desktop ignores ownership). `SKIP_CHOWN=1` / `SKIP_PERSIST=1` opt out.
- Compose files: `${ROOT_VOLUME_DIR:?error}` now reads `${ROOT_VOLUME_DIR:?run CreateVolumes.bat or CreateVolumes.sh first}` so the failure says what to do.
- Checked: all 84 bind paths match `CreateVolumes.sh` and `CreateVolumes.bat` with identical case; all files are stored LF in git; no other Windows paths in compose or mounted config files. `/var/run/docker.sock` mounts (Portainer, Gitea runner, Terraform runner, Beats) work on both Docker Desktop and Linux.

## New stacks added (2026-11-16): Analytics

From the "Missing Apps & New Category Suggestions" list. Folder names have no spaces (like `Databases/ApacheCassandra`); `Analytics/Apache Spark` keeps its existing name.

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Apache Flink 2.3 (JobManager + TaskManager) | Analytics/ApacheFlink | .30 / .31 | 8093 UI/REST | Session cluster, 4 slots. Checkpoints and savepoints persist to bind volumes. Connector JARs go in the `jobs` volume and are loaded with `ADD JAR`. |
| Trino 484 | Analytics/Trino | .40 | 8094 | Single node. Catalogs for PostgreSQL, SQL Server, MySQL, MongoDB, ClickHouse and Cassandra (credentials from `.env` via `${ENV:...}`), plus `tpch` and `memory`. |
| JupyterLab (`quay.io/jupyter/pyspark-notebook:spark-4.3.0`) | Analytics/JupyterLab | .50 | 8888 lab, 4040 Spark UI | Mounts the Spark stack's `spark_data` folder at `/opt/spark/data`. Runs the notebook user as UID 185 so the driver and executors write files as the same user. |

Findings while testing:
- **ClickHouse catalog** needs `?compress=0` in its JDBC URL. With compression on, the driver bundled in Trino 484 fails against ClickHouse 26.10 with *Magic is not correct*.
- **Flink 2.x** renamed the checkpoint settings: `execution.checkpointing.dir` / `execution.checkpointing.savepoint-dir` replace `state.checkpoints.dir` / `state.savepoints.dir`.
- **PySpark from JupyterLab on the cluster**: DataFrame and SQL work, but Python UDFs fail with `PYTHON_VERSION_MISMATCH` (notebook Python 3.13, `spark` image workers Python 3.10). Local mode is unaffected. Documented in the JupyterLab ReadMe.
- Starting JupyterLab while the Spark stack is up prints a harmless warning that `spark_data` belongs to another project.

Verification:
- All 49 stacks pass `docker compose config`; no duplicate IPs, host ports, aliases or container names; every bind path exists in both `CreateVolumes` scripts with identical case; `.env` values equal the compose defaults.
- Flink: cluster up with 1 TaskManager / 4 slots; Flink SQL wrote 3 JSON rows to the Kafka stack (`kafka:29092`) through `flink-sql-connector-kafka-5.0.0-2.2` and aggregated them back.
- Trino: starts with every database stack down. With all six up, one query joined PostgreSQL, SQL Server, MySQL, Cassandra and ClickHouse tables; MongoDB, `tpch`, a Mongo → ClickHouse `CREATE TABLE AS` and the HTTP client protocol also worked.
- JupyterLab: token login works; a notebook session ran a job on the Spark cluster (2 executors), wrote Parquet to `/opt/spark/data` and read it back; the `trino` Python client queried Trino into pandas.

## New stacks added (2026-11-16): Authentication

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| authentik 2026.8.5 (server + worker) | Authentication/Authentik | .30 db-init, .31 server, .32 worker | 8290, 8445 (HTTPS) | PostgreSQL stack (`authentik` database). Bootstrap admin `akadmin` and API token from `.env`. Mail to Mailpit. |
| ZITADEL v4.20.3 + Login V2 | Authentication/Zitadel | .40 db-init, .41 (login shares it) | 8300 console/API, 8301 login | PostgreSQL stack (`zitadel` database). The login container uses `network_mode: service:zitadel` instead of Traefik. |
| Authelia 4.39 | Authentication/Authelia | .50 cert/key init, .51 | 9095 (HTTPS) | Portal `https://auth.dev.localhost:9095`, cookie domain `dev.localhost`. File users, SQLite, OIDC client `dotnet-dev`. Mail to Mailpit. |
| Ory Kratos + Hydra v26.2.0 + self-service UI | Authentication/Ory | .60 db-init, .61/.63 migrations, .62 Kratos, .64 Hydra, .65 UI | 4433/4434, 4444/4445, 4455 | PostgreSQL stack (`kratos`, `hydra` databases). Hydra delegates login/consent to the UI with Kratos sessions. Mail to Mailpit. |

Each PostgreSQL-backed stack has a one-shot `*-db-init` container (`postgres:18` psql client) that creates its database if missing, so there is no manual `CREATE DATABASE` step (unlike Keycloak and SuperTokens).

Nginx Proxy Manager now mounts `RP-LB/NginxProxyManager/snippets` at `/snippets`, with Authelia's `proxy.conf`, `authelia-location.conf` and `authelia-authrequest.conf` (upstream changed to `https://authelia:9091`).

Findings while testing:
- **IPv6-only listeners**: authentik (`[::]`) and the ZITADEL login (Next.js, `::`) failed with *Address family not supported* where containers have no IPv6. Fixed with `AUTHENTIK_LISTEN__*=0.0.0.0:...` and `HOSTNAME=0.0.0.0`.
- **authentik 2026.8** OAuth2 providers have an explicit `grant_types` list; providers created through the API start empty and every token request fails with *Invalid grant_type for provider*.
- **ZITADEL** resolves the instance from the Host header, so containers must call `http://zitadel:8080` with `Host: localhost:8300`.
- **Authelia** rejects a cookie domain without a dot and non-HTTPS portal URLs, hence `dev.localhost` and a generated self-signed certificate. Its template filter also evaluates `{{ }}` inside YAML comments. Non-browser clients may need a hosts entry for `auth.dev.localhost`.
- **Ory UI**: `HYDRA_ADMIN_URL` with a trailing `/` makes the UI call `//admin/...` and consent fails with a 404.

Verification:
- All stacks pass `docker compose config`; no duplicate IPs, host ports, aliases or container names; bind paths are in both `CreateVolumes` scripts; `.env` values equal the compose defaults.
- authentik: started against the PostgreSQL stack from an empty database; API token works; `akadmin` password login through the default authentication flow; created an OIDC application through the API and completed the authorization-code flow (ID token) and client credentials; test mail arrived in Mailpit.
- ZITADEL: headless Chrome opened the console, was redirected to the Login V2 UI on 8301, signed in as the bootstrap admin and returned to the console.
- Authelia: headless Chrome completed the OIDC authorization-code flow (login, consent, code, token exchange) for `dotnet-dev`; Nginx Proxy Manager 2.17 with the snippets protected `https://mailpit.dev.localhost` (redirect to the portal, login, back to Mailpit).
- Ory: headless Chrome registered a user, verified the email with the code from Mailpit, then signed in through Hydra (Kratos login, consent) and exchanged the code for access, ID (with the `email` claim) and refresh tokens; client credentials also issued a token.

## New stacks added (2026-11-16): CloudEmulators

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Azure Event Hubs emulator 2.2.1 | CloudEmulators/AzureEventHubs | .40 | 5674 AMQP, 9094 Kafka, 5301 health | Uses the Azurite stack. Hubs and consumer groups in `Config.json` (`eh1`, `cg1`). |
| Floci 2.5.0 | CloudEmulators/Floci | .50 | 4566 | MIT-licensed AWS emulator, no account. `hybrid` storage persisted to the data folder. Docker socket for Lambda etc. |
| LocalStack 2026.10 | CloudEmulators/LocalStack | .60 | 4567 | Official image; needs `LOCALSTACK_AUTH_TOKEN` (free tier is non-commercial). |
| Pub/Sub emulator (gcloud 593.0.0) | CloudEmulators/GcpPubSub | .70 | 8095 | In-memory. |
| Firestore emulator (gcloud 593.0.0) | CloudEmulators/GcpFirestore | .80 | 8096 | In-memory; explicit HTTP exports to the data folder, newest one imported on start. |
| Spanner emulator 1.5.59 | CloudEmulators/GcpSpanner | .90 | 9011 gRPC, 9020 REST | In-memory. |
| Lowkey Vault 7.4.0 | CloudEmulators/LowkeyVault | .100 | 8446 HTTPS API, 8097 metadata | Azure Key Vault emulator with a simulated managed identity endpoint. Auto-export/import of `export.json`. |

Decision: LocalStack has required an account and auth token since release 2026.03 (4.14 was the last token-free version), so the token-free Floci is the default AWS emulator on 4566 and LocalStack moved to 4567.

Findings while testing:
- **Event Hubs over Kafka**: the emulator advertises the host and port from the SASL password's connection string, so Kafka clients must use `Endpoint=sb://localhost:9094;...` (the Kafka port), not the AMQP port.
- **Firestore persistence**: `--export-on-exit` never ran when Docker stopped the container (SIGTERM and SIGINT, via gcloud and with the emulator's Java process as PID 1). The stack runs the Java process directly and imports the newest export written by the emulator's HTTP export endpoint.
- **Lowkey Vault import**: importing an export while the default vaults are auto-registered fails with *Vault is already created*; the start command adds `--LOWKEY_VAULT_NAMES=-` once an export exists.
- **LocalStack without a token** exits with *License activation failed* (exit code 55) and restarts in a loop.

Verification:
- All stacks pass `docker compose config`; no duplicate IPs, host ports, aliases or container names; bind paths are in both `CreateVolumes` scripts; `.env` values equal the compose defaults.
- Event Hubs: Python `azure-eventhub` sent and received over AMQP on 5674; `confluent-kafka` produced and consumed over the Kafka endpoint on 9094 (and saw the AMQP events).
- Floci: AWS CLI against S3, SQS, DynamoDB and Secrets Manager; all data present after a restart; a Python Lambda function was created and invoked (ran in a sibling container).
- Pub/Sub, Firestore, Spanner: Google's Python client libraries created a topic/subscription and pulled a message, wrote and read a document, created an instance/database/table and queried rows; the ReadMe's gcloud commands created a Spanner instance and database; a Firestore export was imported after recreating the container.
- Lowkey Vault: Python `azure-keyvault-secrets` with `ManagedIdentityCredential` against the simulated token endpoint set and read a secret; the secret survived a container recreate; `https://lowkey-vault:8443` answered from another container.
- LocalStack: only the start-up without a token was tested (no token available).

## New stacks added (2026-11-16): CodeAnalysis

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| OWASP Dependency-Track 5.2.1 (API server + frontend) | CodeAnalysis/DependencyTrack | .20 db-init, .21 API, .22 UI | 8098 API, 8099 UI | v5 (PostgreSQL only) from `ghcr.io/dependencytrack`; `dtrack` database in the PostgreSQL stack. First login `admin` / `admin` with a forced password change. |
| Trivy 0.76.2 (server mode) | CodeAnalysis/Trivy | .30 | 4954 | Vulnerability database cached in the `cache` folder; clients use `--server` and `--token`. |
| DefectDojo 3.5.103 | CodeAnalysis/DefectDojo | .40 db-init, .41 initializer, .42 uWSGI, .43 beat, .44 worker, .45 nginx, .46 Valkey | 8102 | `defectdojo` database in the PostgreSQL stack; private Valkey for Celery. Admin `admin` / `Password123`. |

Decision: the suggestion list named Dependency-Track generally; v5 is its current release (the project's own compose file uses 5.2.1; 4.14.6 is the last 4.x).

Verification:
- All stacks pass `docker compose config`; no duplicate IPs, host ports, aliases or container names; bind paths are in both `CreateVolumes` scripts; `.env` values equal the compose defaults.
- Dependency-Track: forced password change and login through the API; a CycloneDX SBOM generated by Trivy (154 components) uploaded with `autoCreate`; the ReadMe's `curl` upload with an Automation-team API key. Vulnerability analysis needs the API server to mirror NVD/OSV from the internet, which wasn't possible from the test environment.
- Trivy: server healthy with the database in the cache folder; a client `trivy image --server ... --token ...` scan of `postgres:18` returned findings; a wrong token was rejected.
- DefectDojo: initializer loaded the schema and created the admin; `/api/v2/import-scan/` imported the Trivy JSON report (502 findings, product and engagement auto-created) and `/api/v2/reimport-scan/` reused the same test; the scan type names used in the ReadMe exist; no errors in uWSGI, beat or worker logs.

## New stacks added (2026-11-16): Containerization

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Dozzle v11.4.3 | Containerization/Dozzle | .20 | 8103 | Live logs of all containers; Docker socket read-only; actions on, shell off. |
| zot v2.1.23 | Containerization/Zot | .30 | 5002 | OCI registry with UI, search and Trivy CVE scanning; `config.json` in the stack folder. |
| Harbor v2.15.5 (with Trivy) | Containerization/Harbor | .40-.49 | 8104 | Built from the output of Harbor's `prepare` step; PostgreSQL stack for the database (dedicated `harbor` role). |

Harbor design: the installer's generated compose file and configs were adapted instead of being used as-is. Services are renamed `harbor-*` (the defaults `redis`, `registry`, `core`, `portal` would collide with other stacks' aliases), the static configs live in `Containerization/Harbor/config` (mode 644: the containers run as non-root and couldn't read the installer's 600 files), shared secrets are `.env` values, and the one-shot `harbor-init` generates the secret key, the token signing key pair (`openssl genrsa -traditional`, the format Harbor writes) and the registry htpasswd file into the data folders, so no private key is committed. The `harbor-log` syslog container is dropped.

`Claude outputs/Move-EnvFiles.ps1` moves the `<Tool>.env` files delivered in `Claude outputs` into their stack folders.

Verification:
- All stacks pass `docker compose config`; no duplicate IPs, host ports, aliases or container names; bind paths are in both `CreateVolumes` scripts; `.env` values equal the compose defaults; stack folder names are unique.
- Dozzle: healthy; headless Chrome showed the container list.
- zot: `docker push`/`pull` of `localhost:5002/demo/alpine:3.22`, catalog and GraphQL search. The CVE database download needs internet access from the container (not available in the test environment).
- Harbor: all components healthy; `docker login`, push and pull through `localhost:8104`; artifact listed by the API; UI login in headless Chrome; a Trivy scan of the pushed image succeeded (with the database pre-seeded, as the test environment's containers had no internet); after `docker compose down`/`up` the secret key was unchanged and the image still pulled.
- `Move-EnvFiles.ps1`: tested with PowerShell 7.5 (`-WhatIf`, real move replacing an existing `.env`, unknown name skipped with a warning).

## New stacks added (2026-11-16): Databases

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| RavenDB 7.2 | Databases/RavenDB | .160 | 8105, 38888 | Unsecured dev mode. Listens on the host port numbers inside the container (it calls itself on its public URL `http://localhost:8105`). |
| CouchDB 3.5.3 | Databases/CouchDB | .170/.171 | 5984 | `couchdb-init` runs `_cluster_setup` single-node once. |
| Couchbase Server CE 8.0.2 | Databases/Couchbase | .180/.181 | 8107-8110, 11210 | `couchbase-init` initialises the cluster and bucket `dev`, and registers the remapped ports as external alternate addresses. |
| Garnet 2.1 | Databases/Garnet | .190 | 6380 | Redis protocol; checkpoints to the data folder and recovers on start. |
| Memcached 1.6 | Databases/Memcached | .200 | 11211 | No volume. |
| Qdrant v1.20.2 | Databases/Qdrant | .210 | 6333, 6334 | API key `Password123`. |
| ScyllaDB 2026.3 | Databases/ScyllaDB | .220 | 9043, 8106 | Developer mode; CQL plus Alternator (DynamoDB API). |
| CloudBeaver 26.2.5 | Databases/CloudBeaver | .230 | 8978 | Auto-configured admin; six seeded connections to the SQL stacks. |
| TimescaleDB 2.32.0-pg18 | Databases/TimescaleDB | .240 | 5433 | PostgreSQL 18 + TimescaleDB. |
| Valkey 9.0 | Databases/Valkey | .250 | 6381 | AOF persistence. |

Changes to existing stacks:
- **PostgreSQL** now uses `pgvector/pgvector:pg18-trixie` (same Debian base as `postgres:18`; tested against a data folder created by `postgres:18`). The image variable is now `PGVECTOR_VERSION`.
- **EventStoreDb → KurrentDB** (`kurrentplatform/kurrentdb:26.2`): new folder, container `kurrentdb`, new data folder `Databases/KurrentDB`, gRPC on 2113 only (port 1113 is gone), `KURRENTDB_*` settings. The `eventstoredb` alias is kept. The old `Databases/EventStoreDb` volume folder is not touched; the old Docker volumes `eventstore-volume-data` / `eventstore-volume-logs` can be removed with `docker volume rm`.
- **Prometheus** moved to `Observability/Prometheus`: IPs 172.20.11.30-.32, data under `docker/volumes/Observability/Prometheus`. The alias `prometheus`, port 9090 and the volume names are unchanged, so Docker must forget the old volume definitions once (`docker volume rm prometheus_data alertmanager_data`, which doesn't delete the files).

## New stacks added (2026-11-16): Documentation

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Wiki.js 3.4 | Documentation/WikiJs | .30/.31 | 3003 | PostgreSQL stack (needs PG 17+); admin from `.env` on first start. |
| BookStack 26.09.3 | Documentation/BookStack | .40/.41 | 6875 | MariaDB stack; mail to Mailpit. Entrypoint drops nginx's `[::]` listener when the host has no IPv6. |
| Outline 1.13.0 + Dex v2.41.1 | Documentation/Outline | .50-.53 | 3002, 5556 | PostgreSQL stack, own Redis, local file storage. Outline has no local accounts, so Dex (static user in `dex.yaml`, rendered with gomplate) provides the OIDC login. |
| Structurizr 2026.10.26 (`local`) | Documentation/Structurizr | .60 | 8112 | Structurizr Lite is end-of-life; the consolidated `structurizr/structurizr` image's `local` command replaces it. |
| Kroki 0.36.0 | Documentation/Kroki | .70-.73 | 8000 | Main server plus Mermaid, BPMN and Excalidraw companions; stateless. Kroki includes PlantUML, so no separate PlantUML server. |
| draw.io 32.6.10 | Documentation/DrawIo | .80 | 8111 | Stateless editor. |
| Swagger UI v5.35.0 + Redoc 3.1.0 | Documentation/ApiDocs | .90/.91 | 8113, 8114 | Serve `./specs` (sample spec included); specs from running apps are fetched by the browser. |

## New stacks added (2026-11-16): Email and IaC

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| smtp4dev 3.16.1 | Email/Smtp4dev | 8.20 | 8115 UI, 2525 SMTP, 1143 IMAP, 1110 POP3 | .NET fake SMTP server; mailbox readable over IMAP/POP3. |
| OpenTofu 1.13.9 | IaC/OpenTofu | 9.20 | - | CLI container like the Terraform one. |
| Atlantis v0.49.0 | IaC/Atlantis | 9.30/9.31 | 4141 | PR-driven plan/apply on the Gitea stack. `atlantis-init` creates the bot user and token; the entrypoint rewrites Gitea's public clone URLs to `gitea:3000`. Tested: webhook → autoplan → `atlantis plan` / `atlantis apply` comments and commit statuses. |
| Semaphore UI v2.20.24 | IaC/Semaphore | 9.40/9.41 | 3004 | PostgreSQL stack; admin from `.env`; alerts to Mailpit. |

Changes to existing stacks:
- **IaC/Terraform**: Gaia, its runner and MongoDB 4.4 removed (unmaintained). The `IaC/Terraform/data` volume folder is no longer used, and the old containers (`gaia`, `runner`, `gaia-mongo`) and volume `terraform_data` can be removed with `docker rm -f` / `docker volume rm`.
- **SourceControl/Gitea**: `GITEA__webhook__ALLOWED_HOST_LIST` = `GITEA_WEBHOOK_ALLOWED_HOSTS` (`external,private`) so webhooks can reach GroupNetwork services.

## New stacks added (2026-11-16): Messaging

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| NATS 2.15.3 | Messaging/NATS | 10.30 | 4222, 8222 | JetStream on; user/password from `.env` via `nats-server.conf`. |
| Mosquitto 2.1.2 | Messaging/Mosquitto | 10.40 | 1883, 9002 (WebSockets) | Anonymous refused; password file generated from `.env` on every start. |
| Apache Artemis 2.57.0 | Messaging/Artemis | 10.50 | 61616, 5675 (AMQP), 61613 (STOMP), 8161 | The project was renamed from ActiveMQ Artemis; image is now `apache/artemis`. `maxDiskUsage` disabled (-1) because the 90% default blocks producers on full dev disks. |
| Redpanda v26.2.7 + Console v3.14.0 | Messaging/Redpanda | 10.60/10.61 | 19092, 18081, 18082, 9644, 8116 | Kafka API, Schema Registry and HTTP proxy; dev-container mode. |
| Apache Pulsar 5.0.1 | Messaging/Pulsar | 10.70 | 6650, 8117 | Standalone, functions worker and stream storage off. No UI (Pulsar Manager unmaintained since 2023). |
| Debezium 3.7 (Kafka Connect) | Messaging/Debezium | 10.80 | 8118 | Image is on quay.io (Docker Hub stopped at 3.0). Sample PostgreSQL connector in `postgres-connector.json`; tested snapshot + update events. |
| Apicurio Registry 3.3.4 + UI | Messaging/Apicurio | 10.90-10.92 | 8119, 8120 | PostgreSQL storage; Confluent-compatible API at `/apis/ccompat/v7`. |

Changes to existing stacks:
- **Databases/PostgreSQL**: `wal_level=logical` (plus `max_replication_slots` / `max_wal_senders`) via `command:` and `.env`, for Debezium. Needs one restart.
- **Messaging/Kafka**: Kafka UI lists the Debezium Connect cluster and uses Apicurio as schema registry.

## New stacks added (2026-11-16): Observability

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Jaeger 2.23.0 | Observability/Jaeger | 11.40 | 16686, 14317, 14318 | Badger storage on a volume (7-day TTL). Query API is `/api/v3`, so no Grafana Jaeger data source (Tempo covers traces in Grafana). Self-tracing turned off. |
| Grafana Pyroscope 1.21.1 | Observability/Pyroscope | 11.50 | 4041 | Provisioned in Grafana as data source `pyroscope`. |
| Uptime Kuma 2.5.11 | Observability/UptimeKuma | 11.60 | 3005 | `UPTIME_KUMA_DB_TYPE=sqlite` skips the database-choice page. |
| cAdvisor 0.61.0 | Observability/cAdvisor | 11.70 | 8121 | Scraped by Prometheus (job `cadvisor`). Entrypoint picks the containerd socket (`/run/containerd` or dockerd-managed `/var/run/docker/containerd`). |
| grafana/otel-lgtm 0.41.0 | Observability/OtelLgtm | 11.80 | 3006, 24317, 24318 | All-in-one Collector + Prometheus + Tempo + Loki + Pyroscope + Grafana. |
| SigNoz v0.150.0 | Observability/SigNoz | 11.90-11.96 | 8122, 34317, 34318 | Generated with SigNoz Foundry (`foundryctl forge`, the old deploy/ Compose files are deprecated) and adapted: metadata in the PostgreSQL stack, pinned images, bind volumes, short aliases. Collector accepts OTLP only after the first admin is created. |

Changes to existing stacks:
- **Observability/Prometheus**: scrape job `cadvisor`.
- **Visualization/Grafana**: Pyroscope data source.

## New stacks added (2026-11-16): Orchestration

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| K3s v1.37.2 + Argo CD v3.6.1 | Orchestration/K3s | 12.40/12.41 | 6443, 8124 | Privileged K3s server; `k3s-setup` writes a GroupNetwork kubeconfig, generates CoreDNS zones for `K3S_GROUPNETWORK_HOSTS`, installs Argo CD (plain HTTP NodePort 30080, admin / Password123). Traefik disabled. Needs a cgroup v2 Docker host. |
| Headlamp v0.46.0 | Orchestration/Headlamp | 12.50 | 4466 | Uses the K3s stack's GroupNetwork kubeconfig. |
| Nomad 2.1.1 | Orchestration/Nomad | 12.60 | 4646 | Server + client, docker driver via the Docker socket; client fingerprints `lo` so job ports publish on the Docker host's 127.0.0.1. `NOMAD_DATA_DIR` is a fixed Docker-host path (same inside and outside). |

Testing notes: the sandbox could not start pods inside K3s (its runtime may not set `oom_score_adj`), so Argo CD's pods were not seen running; the K3s API, kubeconfigs, Argo CD manifest/patches, CoreDNS zone file (checked in a standalone CoreDNS) and Headlamp against the API were verified. Nomad ran the example job end to end.

## New stacks added (2026-11-16): Packages

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Sonatype Nexus CE 3.98.1 | Packages/Nexus | 13.20/13.21 | 8125 | `nexus-init`: anonymous read, NuGet API-key / npm / Docker token realms, and (with `NEXUS_ACCEPT_EULA=true`, the owner's choice) accepts the CE EULA + mandatory telemetry, without which uploads return 403. Tested: NuGet upload, v3 search and download through `nuget-group`. |
| BaGetter 1.6.5 | Packages/BaGetter | 13.30 | 5555 | SQLite + file storage; API key for push; nuget.org mirror. Tested push / wrong-key 401 / search / download. |
| Verdaccio 7.1.1 | Packages/Verdaccio | 13.40 | 4873 | `@local` scope private; everything else proxied from npmjs.org. Tested adduser, publish, install, anonymous 401. |

Not changed: Packages/Proget still pins `24.0.2` (ProGet 2025 exists) - flagged for a separate upgrade.

## New stacks added (2026-11-16): RP-LB

All five front the Nginx and Apache stacks like HAProxy does. Tested each with round-robin, failover when one backend stops (active health checks), and the reload path in its ReadMe.

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Traefik v3.7.19 | RP-LB/Traefik | 14.30 | 8126 HTTP, 8127 dashboard | Docker-label provider (`exposedbydefault=false`, socket read-only) + watched `dynamic/` file provider (`/web` route). Insecure dashboard - local only. Tested label routing with a throwaway container. |
| Caddy 2.11.9 | RP-LB/Caddy | 14.40 | 8128 HTTP, 8134 HTTPS | `local_certs` (no ACME), `auto_https disable_redirects` so the plain-HTTP site isn't redirected, `skip_install_trust`. Root CA lands in the data volume. Also covers the WebServers "Caddy" suggestion. |
| YARP 2.3.0 | RP-LB/Yarp | 14.50 | 8129 | No stable official image (only `dotnet/nightly/yarp` previews), so a minimal ASP.NET Core 10 host is built from `src/`. Routes in `config/proxy.json` (folder mount + polling watcher; a single-file mount missed edits that replace the file). |
| Envoy v1.39.6 | RP-LB/Envoy | 14.60 | 8130, 9902 admin | Static `envoy.yaml`, `STRICT_DNS` cluster, HTTP health check. |
| Kong 3.9.4 | RP-LB/Kong | 14.70 | 8131 proxy, 8132 admin, 8133 Manager | Last OSS image (newer = `kong/kong-gateway` Enterprise free mode). DB-less `kong.yml` with rate-limiting + correlation-id; hot reload via `POST /config` tested. |

Ports 8000/8001 (Kong defaults) are taken by Kroki and `kubectl proxy`; 8443 by authentik, hence the 81xx block.

## New stacks added (2026-11-16): Scheduling

All four keep their state in the PostgreSQL stack (dedicated role + database per tool, created by a `*-db-init` one-shot) and were tested against it, including a second `up` to confirm the setup containers are safe to rerun.

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Temporal 1.32.2 + UI 2.58.1 | Scheduling/Temporal | 15.20-15.24 | 7233 gRPC, 8135 UI | `auto-setup` image ended at 1.29, so this follows Temporal's current samples-server layout: `temporal-schema` (admin-tools `temporal-sql-tool`, setup + update, fails loudly) and `temporal-namespace-init`. Tested a Schedule firing a workflow, schema version stable on rerun. |
| Airflow 3.4.0 | Scheduling/Airflow | 15.30-15.35 | 8136 | LocalExecutor (no Celery/Redis), FAB auth manager. `airflow-init` migrates and creates the admin or resets its password. Sample DAG in `dags/`. Tested token auth, manual run of the sample DAG (dynamic task mapping) and task logs on the volume. |
| Rundeck 6.3.0 | Scheduling/Rundeck | 15.40/15.41 | 4440 | Entrypoint wrapper writes `realm.properties` (admin password) and a static API token file from `.env`; default `admin/admin` rejected. Tested project + cron job import, scheduled execution and output via API v60, persistence across restart. |
| n8n 2.47.7 | Scheduling/N8n | 15.50-15.53 | 5678 | Latest stable (`latest`/`stable` tags; 3.x git tags aren't published as images). `N8N_LISTEN_ADDRESS=0.0.0.0` (default `::` fails without IPv6), external `n8nio/runners` for Code nodes (internal mode is deprecated), `n8n-init` creates the owner. Tested a scheduled workflow through JavaScript and Python Code nodes. |

## New stacks added (2026-11-16): Search

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Meilisearch v1.57.0 | Search/Meilisearch | 16.30 | 7700 | Master key in `.env`, `MEILI_ENV=development` (mini dashboard), analytics off. Tested 401 without key, typo search, default API keys, persistence. |
| Typesense 30.2 | Search/Typesense | 16.40 | 8137 | Default 8108 is taken by Couchbase. Bootstrap API key in `.env`, CORS on. Tested 401 without key, collection + import + typo search, persistence. No healthcheck (the image has no curl/wget). |
| Apache Solr 10.1.0 | Search/Solr | 16.50 | 8983 | Standalone mode, `solr-precreate` makes the `dev` core once. No auth. Tested JSON update, fuzzy query, admin UI, persistence. |

Changed in existing stacks:
- **Elastic 8.7.1 -> 9.5.6** (owner chose fresh data; the ReadMe explains the 8.19 step for keeping indices). Fixes needed for 9.x: Beats now require `--strict.perms` (double dash); Logstash refuses root, so it runs as `1000:0` (group 0 reads the es-setup certs) and `CreateVolumes.sh` owns `logstashdata01`; Logstash's removed `cacert` option became `ssl_certificate_authorities`. `LS_MEM_LIMIT` was in `.env` but unused - now Logstash's `mem_limit`. `.env` regrouped under the standard headers (same variable names). Tested the full stack: Kibana available, Filebeat container logs, Metricbeat (incl. Logstash API), Logstash file input -> `logstash-*`.
- **OpenSearch** `latest` pinned to `3.9.0` (what `latest` resolved to). Ports moved under "Host ports" in `.env`. Tested node + Dashboards 3.9.0.

## New stacks added (2026-11-16): Security

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| OpenBao 2.7.2 | Security/OpenBao | 17.20 | 8202 | No init/unseal routine: `seal "static"` with a 32-byte key from `.env` (written to /tmp by the entrypoint) and declarative `initialize` blocks (admin policy, userpass `admin`, KV v2 at `secret/`). Single-node Raft (OpenBao dropped the file backend). Tested login, KV write/read via API and `bao` CLI, restart comes back unsealed. |
| step-ca 0.30.2 | Security/StepCa | 17.30 | 9003 | Initialized from `DOCKER_STEPCA_INIT_*` on first start, ACME provisioner on. Tested a JWK-provisioner certificate and a full ACME http-01 order from another GroupNetwork container (cert verifies against the root). |
| ZAP 2.17.0 | Security/Zap | 17.40/17.41 | 8140 proxy+API, 8139 UI | Webswing only starts ZAP when the page is opened, so the headless daemon is the default service and the browser UI is `--profile ui`. Daemon listens on the host port number inside (ZAP proxies requests whose Host isn't its own). Tested API key enforcement, proxying, spider + passive alerts, HTML report, UI page. Shared root CA in `wrk`. |
| Infisical v0.167.11 | Security/Infisical | 17.50-17.52 | 8138 | Uses the PostgreSQL and Redis stacks instead of its own. `infisical-init` calls `/api/v1/admin/bootstrap` (admin + org, prints a one-time machine identity token; rerun is a no-op). Tested project creation and secret write/read with that token. |

Changed in existing stacks:
- **Vault** `latest` pinned to `2.2.2` (what `latest` resolved to); tested init/unseal with the existing `vault.hcl`. ReadMe points to OpenBao as the auto-unsealing alternative.

## New stacks added (2026-11-16): SIEM

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Graylog Open 7.2.2 + Data Node 7.2.2 + MongoDB 8.0 | SIEM/Graylog | 18.20-18.22 | 9004 UI, 12201 GELF tcp/udp, 5140 syslog tcp/udp, 5044 Beats | `GRAYLOG_SELFSIGNED_STARTUP=true` creates the internal CA and provisions the data node (no preflight wizard). Admin password is plain in `.env`; the entrypoint derives `GRAYLOG_ROOT_PASSWORD_SHA2`. Own MongoDB 8.0 because the shared stack is on 9.x (see flagged item 9). Raw input port 5555 not published (BaGetter). Tested: admin login/401, GELF UDP input created via API, messages searchable, persistence across restart. In the sandbox OpenSearch needed a test-only override (file-handle limit 20000 < 65535); hosts with Docker Desktop/normal Linux limits don't. |

## New stacks added (2026-11-16): SourceControl

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Forgejo 17.0.1 + runner 13.2.1 | SourceControl/Forgejo | 19.20-19.22 | 3007 HTTP, 2223 SSH | `INSTALL_LOCK`; `forgejo-init` (Forgejo image, same volume, UID 1000) creates `forgejo-admin` or resets its password and writes a runner registration token (`generate-runner-token`; `LOCAL_ROOT_URL=http://forgejo:3000/` so the CLI reaches the server). Runner registers once, then daemon; jobs on GroupNetwork. Tested: API auth/401, repo create, workflow run succeeded (incl. curl to `forgejo:3000`), HTTP clone, restart without re-registration. |
| GitLab CE 19.5.6 | SourceControl/GitLab | 19.30 | 8141 HTTP (same inside), 2224 SSH | Trimmed Omnibus config (Puma single mode, Sidekiq 10, Prometheus/registry/KAS off), ~3 GB RAM. Root password must pass GitLab's checks: `Dev!GitLab#2026` was rejected as a common combination and GitLab then created no root user, so `.env` has a random one. Tested sign-in, PAT + API project, clone/push, access as `http://gitlab:8141` from GroupNetwork. |
| OneDev 17.2.1 | SourceControl/OneDev | 19.40 | 6610 HTTP, 6611 SSH | `initial_*` env vars skip the setup page; embedded DB; Docker socket for CI. Tested REST auth/401, project create, push, buildspec job SUCCESSFUL, persistence across restart. |

Changed in existing stacks:
- **Gitea** `latest` pinned to `28.4.0` and runner `latest` to `6.0.0` (what `latest` resolved to).

## New stacks added (2026-11-16): Visualization

| Stack | Folder | IP | Host ports | Notes |
|---|---|---|---|---|
| Metabase v0.65.4.5 | Visualization/Metabase | 20.20-20.22 | 3008 | App DB in the PostgreSQL stack. `metabase-init` (curl image) completes `/api/setup` while a setup token exists. `MB_PASSWORD_COMPLEXITY=weak` because the normal policy rejects `Password123` as too common. Tested login/401, adding the Postgres stack as a database, native query, restart. |
| Superset 6.1.0 | Visualization/Superset | 20.30-20.32 | 8142 | Built image `superset-drivers` (official image has no drivers): psycopg2, pymssql, pymysql. `superset-init`: db upgrade, create admin or reset password, init. No Celery/Redis. Tested JWT login/401, database connection + SQL Lab query (with CSRF token), SQL Server driver loads, password reset path. |
| Redash 26.9.0 | Visualization/Redash | 20.40-20.44 | 8143 | PostgreSQL + Redis stacks. `redash-init`: create_tables (empty DB only), db upgrade, create_root once. `REDASH_GUNICORN_BIND=0.0.0.0:5000` (default `[::]` crash-loops without IPv6). One worker for all queues. Tested login, data source, async query through the worker, init rerun. |

Changed in existing stacks:
- **Grafana** `latest` pinned to `13.3.1` (what `latest` resolved to).
