# Docker-Scripts
Collection of Docker and Docker Compose scripts

## Getting started
1. `CreateNetwork.bat` / `CreateNetwork.sh` - creates the shared `GroupNetwork` (172.20.0.0/16) every stack attaches to.
2. `CreateVolumes.bat` / `CreateVolumes.sh` - creates the host folders behind the bind-mounted volumes and saves `ROOT_VOLUME_DIR` for your user, then open a new terminal.
3. `cd <Category>/<Tool>` then `docker compose up -d`.

### Windows and Linux/macOS
The stacks are OS-agnostic: the only host-specific value is `ROOT_VOLUME_DIR`, the folder that holds `docker/volumes/...`.
It is set once per machine as an environment variable rather than in each `.env`:

| OS | Command | Default root | Saved to |
|----|---------|--------------|----------|
| Windows | `CreateVolumes.bat [root]` | `D:` | user environment variable (`setx`) |
| Linux / macOS | `./CreateVolumes.sh [root]` | `$HOME` | `~/.bashrc`, `~/.zshenv` or `~/.profile` (by shell) |

Pass a root to use a different location, e.g. `CreateVolumes.bat C:\dev` or `./CreateVolumes.sh /srv/docker`.
If `ROOT_VOLUME_DIR` is missing, `docker compose` stops with *run CreateVolumes.bat or CreateVolumes.sh first*
instead of binding volumes to the wrong place. To point a single stack somewhere else, uncomment `ROOT_VOLUME_DIR` in its `.env`.

On native Linux the script also `chown`s the folders of images that run as a fixed non-root user (Grafana, Prometheus,
Tempo/Loki, Elasticsearch, OpenSearch, Solr, SonarQube, Dependency-Track, DefectDojo, pgAdmin, Vault, authentik, Kafka, Spark, Flink, JupyterLab, Airflow, n8n, Rundeck, Nexus, Verdaccio, Jaeger, Pyroscope, SigNoz, TeamCity, Woodpecker, k6, GrowthBook, RustFS, Dapr scheduler, Langfuse ClickHouse, Camunda, Node-RED, NiFi, Mattermost, Plane S3 store, code-server, Artemis, Redpanda, Pulsar, Atlantis, Semaphore, Wiki.js, Outline, Structurizr, Oracle, KurrentDB, Garnet, RavenDB, ScyllaDB, Wazuh), using `sudo`.
Docker Desktop ignores bind-mount ownership, so Windows and macOS skip this. Set `SKIP_CHOWN=1` or `SKIP_PERSIST=1` to opt out.

## Configuration (.env)
Every settable value lives in the stack's `.env`, grouped as **Image versions**, **Host ports**, **Network (static IPs)**,
**Credentials & settings** and **Tuning**. The compose files reference them as `${VAR:-default}`, so:
- edit the `.env` to change a password, port, image tag or IP - no compose edits needed;
- a variable missing from `.env` falls back to the compose default (the same value), so stacks still start;
- a shell/environment variable overrides the `.env`, e.g. `KAFKA_PORT=19092 docker compose up -d`;
- `docker compose config` shows the fully resolved result.

Values that are internal wiring (container-side ports, service DNS names, certificate paths, cluster topology)
stay in `docker-compose.yml` on purpose - changing them would break the stack.
Credentials such as `*_PASSWORD` are usually only applied the first time a data folder is initialised.
Passwords in this repo (`Password123`, etc.) are local-development defaults only.

# Networking
Every stack joins the external `GroupNetwork` bridge, **172.20.0.0/16**, with a static IP laid out as `172.20.<category>.<tool + n>`:

- **3rd octet = top-level folder (category).** Assigned alphabetically from `.1`; `.0` holds the gateway and is left for Docker to hand out to any container without a static IP.
- **4th octet = tool folder within the category.** Each tool gets a block of 10 starting at its base (1st tool `.10`, 2nd `.20`, ...). A stack with several containers uses consecutive addresses in its block (`.10`, `.11`, ...), so a tool can grow to 10 containers without touching its neighbours.
- New category: next free 3rd octet. New tool: next free block of 10 in its category. Update the tables below, the stack's `.env` and its compose defaults together.

## Global
|Name|Subnet / IP|
|:----------|:----------|
|GroupNetwork| 172.20.0.0/16|
|Gateway    | 172.20.0.1|

## Category map (3rd octet)
|Category|Range|
|:----------|:----------|
|Analytics| 172.20.1.0/24|
|Authentication| 172.20.2.0/24|
|CloudEmulators| 172.20.3.0/24|
|CodeAnalysis| 172.20.4.0/24|
|Containerization| 172.20.5.0/24|
|Databases| 172.20.6.0/24|
|Documentation| 172.20.7.0/24|
|Email| 172.20.8.0/24|
|IaC| 172.20.9.0/24|
|Messaging| 172.20.10.0/24|
|Observability| 172.20.11.0/24|
|Orchestration| 172.20.12.0/24|
|Packages| 172.20.13.0/24|
|RP-LB| 172.20.14.0/24|
|Scheduling| 172.20.15.0/24|
|Search| 172.20.16.0/24|
|Security| 172.20.17.0/24|
|SIEM| 172.20.18.0/24|
|SourceControl| 172.20.19.0/24|
|Visualization| 172.20.20.0/24|
|WebServers| 172.20.21.0/24|
|CI-CD| 172.20.22.0/24|
|Testing| 172.20.23.0/24|
|FeatureFlags| 172.20.24.0/24|
|ObjectStorage| 172.20.25.0/24|
|ServiceMesh| 172.20.26.0/24|
|AI| 172.20.27.0/24|
|DataIntegration| 172.20.28.0/24|
|Collaboration| 172.20.29.0/24|
|DevTools| 172.20.30.0/24|

**URL column:** the host-side address published by each container (browser links open the UI; database/broker entries show a client connection string). `- (internal)` = no host port, reach it on `GroupNetwork` by alias; `- (one-shot)` = setup container that exits.

## Analytics (172.20.1.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Apache Spark|Apache Spark (master)| 172.20.1.10| <http://localhost:8090/>|
|Apache Spark|Apache Spark Worker| 172.20.1.11| - (internal)|
|Seq|Seq| 172.20.1.20| <http://localhost:8089/>|
|ApacheFlink|Flink JobManager| 172.20.1.30| <http://localhost:8093/>|
|ApacheFlink|Flink TaskManager| 172.20.1.31| - (internal)|
|Trino|Trino| 172.20.1.40| <http://localhost:8094/>|
|JupyterLab|JupyterLab| 172.20.1.50| <http://localhost:8888/lab?token=Password123>|

## Authentication (172.20.2.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Keycloak|Keycloak| 172.20.2.10| <http://localhost:8280/>|
|Supertokens|SuperTokens| 172.20.2.20| <http://localhost:3567/hello>|
|Authentik|authentik DB setup (one-shot)| 172.20.2.30| - (one-shot)|
|Authentik|authentik server| 172.20.2.31| <http://localhost:8290/>|
|Authentik|authentik worker| 172.20.2.32| - (internal)|
|Zitadel|ZITADEL DB setup (one-shot)| 172.20.2.40| - (one-shot)|
|Zitadel|ZITADEL + Login UI (shared network)| 172.20.2.41| <http://localhost:8300/ui/console>|
|Authelia|Authelia cert/key setup (one-shot)| 172.20.2.50| - (one-shot)|
|Authelia|Authelia| 172.20.2.51| <https://auth.dev.localhost:9095/>|
|Ory|Ory DB setup (one-shot)| 172.20.2.60| - (one-shot)|
|Ory|Kratos migrations (one-shot)| 172.20.2.61| - (one-shot)|
|Ory|Kratos| 172.20.2.62| <http://127.0.0.1:4433/>|
|Ory|Hydra migrations (one-shot)| 172.20.2.63| - (one-shot)|
|Ory|Hydra| 172.20.2.64| <http://localhost:4444/.well-known/openid-configuration>|
|Ory|Kratos self-service UI| 172.20.2.65| <http://127.0.0.1:4455/>|

## CloudEmulators (172.20.3.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|AzureCosmosDb|Azure Cosmos DB emulator| 172.20.3.10| <http://localhost:1234/>|
|AzureServiceBus|Azure Service Bus emulator| 172.20.3.20| `amqp://localhost:5673`|
|Azurite|Azurite| 172.20.3.30| <http://localhost:10000/>|
|AzureEventHubs|Azure Event Hubs emulator| 172.20.3.40| <http://localhost:5301/health>|
|Floci|Floci (AWS emulator)| 172.20.3.50| <http://localhost:4566/_floci/ui>|
|LocalStack|LocalStack (AWS emulator, auth token)| 172.20.3.60| <http://localhost:4567/>|
|GcpPubSub|Google Cloud Pub/Sub emulator| 172.20.3.70| <http://localhost:8095/>|
|GcpFirestore|Google Cloud Firestore emulator| 172.20.3.80| <http://localhost:8096/>|
|GcpSpanner|Google Cloud Spanner emulator| 172.20.3.90| <http://localhost:9020/>|
|LowkeyVault|Lowkey Vault (Azure Key Vault emulator)| 172.20.3.100| <https://localhost:8446/>|

## CodeAnalysis (172.20.4.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Sonarqube|SonarQube| 172.20.4.10| <http://localhost:9000/>|
|DependencyTrack|Dependency-Track DB setup (one-shot)| 172.20.4.20| - (one-shot)|
|DependencyTrack|Dependency-Track API server| 172.20.4.21| <http://localhost:8098/api/version>|
|DependencyTrack|Dependency-Track frontend| 172.20.4.22| <http://localhost:8099/>|
|Trivy|Trivy server| 172.20.4.30| <http://localhost:4954/healthz>|
|DefectDojo|DefectDojo DB setup (one-shot)| 172.20.4.40| - (one-shot)|
|DefectDojo|DefectDojo initializer (one-shot)| 172.20.4.41| - (one-shot)|
|DefectDojo|DefectDojo uWSGI| 172.20.4.42| - (internal)|
|DefectDojo|DefectDojo Celery beat| 172.20.4.43| - (internal)|
|DefectDojo|DefectDojo Celery worker| 172.20.4.44| - (internal)|
|DefectDojo|DefectDojo nginx| 172.20.4.45| <http://localhost:8102/>|
|DefectDojo|DefectDojo Valkey| 172.20.4.46| - (internal)|

## Containerization (172.20.5.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|DockerRegistry|Docker Registry| 172.20.5.10| <http://localhost:5000/v2/>|
|DockerRegistry|Docker Registry UI| 172.20.5.11| <http://localhost:5001/>|
|Dozzle|Dozzle| 172.20.5.20| <http://localhost:8103/>|
|Zot|zot registry| 172.20.5.30| <http://localhost:5002/>|
|Harbor|Harbor DB setup (one-shot)| 172.20.5.40| - (one-shot)|
|Harbor|Harbor key/config setup (one-shot)| 172.20.5.41| - (one-shot)|
|Harbor|Harbor registry| 172.20.5.42| - (internal)|
|Harbor|Harbor registryctl| 172.20.5.43| - (internal)|
|Harbor|Harbor core| 172.20.5.44| - (internal)|
|Harbor|Harbor portal| 172.20.5.45| - (internal)|
|Harbor|Harbor jobservice| 172.20.5.46| - (internal)|
|Harbor|Harbor Redis (Valkey)| 172.20.5.47| - (internal)|
|Harbor|Harbor proxy (nginx)| 172.20.5.48| <http://localhost:8104/>|
|Harbor|Harbor Trivy adapter| 172.20.5.49| - (internal)|

## Databases (172.20.6.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|ApacheCassandra|Apache Cassandra| 172.20.6.10| `cql://localhost:9042`|
|ClickHouse|ClickHouse| 172.20.6.20| <http://localhost:8123/play>|
|CockroachDB|CockroachDB| 172.20.6.30| <http://localhost:8080/>|
|KurrentDB|KurrentDB (formerly EventStoreDB)| 172.20.6.40| <http://localhost:2113/>|
|InfluxDb|InfluxDB| 172.20.6.50| <http://localhost:8086/>|
|MariaDb|MariaDB| 172.20.6.60| `mysql://localhost:3307`|
|MariaDb|Adminer| 172.20.6.61| <http://localhost:8087/>|
|Milvus|Milvus etcd| 172.20.6.70| - (internal)|
|Milvus|Milvus MinIO| 172.20.6.71| <http://localhost:9111/>|
|Milvus|Milvus| 172.20.6.72| `grpc://localhost:19530`|
|MongoDB|MongoDB| 172.20.6.80| `mongodb://localhost:27017`|
|MongoDB|Mongo Express| 172.20.6.81| <http://localhost:8088/>|
|MSSQL|MSSQL| 172.20.6.90| `sqlserver://localhost:1433`|
|MySQL|MySQL| 172.20.6.100| `mysql://localhost:3306`|
|MySQL|phpMyAdmin| 172.20.6.101| <http://localhost:8082/>|
|Neo4J|Neo4j| 172.20.6.110| <http://localhost:7474/>|
|Oracle|Oracle| 172.20.6.120| `oracle://localhost:1521`|
|PostgreSQL|PostgreSQL (with pgvector)| 172.20.6.130| `postgresql://localhost:5432`|
|PostgreSQL|pgAdmin4| 172.20.6.131| <http://localhost:5050/>|
| *(.140-.149 free: Prometheus moved to Observability)*| | |
|Redis|Redis| 172.20.6.150| `redis://localhost:6379`|
|RavenDB|RavenDB| 172.20.6.160| <http://localhost:8105/>|
|CouchDB|CouchDB| 172.20.6.170| <http://localhost:5984/_utils>|
|CouchDB|CouchDB setup (one-shot)| 172.20.6.171| - (one-shot)|
|Couchbase|Couchbase Server CE| 172.20.6.180| <http://localhost:8107/>|
|Couchbase|Couchbase setup (one-shot)| 172.20.6.181| - (one-shot)|
|Garnet|Garnet| 172.20.6.190| `redis://localhost:6380`|
|Memcached|Memcached| 172.20.6.200| `memcached://localhost:11211`|
|Qdrant|Qdrant| 172.20.6.210| <http://localhost:6333/dashboard>|
|ScyllaDB|ScyllaDB| 172.20.6.220| `cql://localhost:9043`|
|CloudBeaver|CloudBeaver| 172.20.6.230| <http://localhost:8978/>|
|TimescaleDB|TimescaleDB| 172.20.6.240| `postgresql://localhost:5433`|
|Valkey|Valkey| 172.20.6.250| `redis://localhost:6381`|

## Documentation (172.20.7.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Backstage|Backstage| 172.20.7.10| <http://localhost:7007/>|
|Mediawiki|MediaWiki| 172.20.7.20| <http://localhost:8281/>|
|WikiJs|Wiki.js DB setup (one-shot)| 172.20.7.30| - (one-shot)|
|WikiJs|Wiki.js| 172.20.7.31| <http://localhost:3003/>|
|BookStack|BookStack DB setup (one-shot)| 172.20.7.40| - (one-shot)|
|BookStack|BookStack| 172.20.7.41| <http://localhost:6875/>|
|Outline|Outline DB setup (one-shot)| 172.20.7.50| - (one-shot)|
|Outline|Outline Redis| 172.20.7.51| - (internal)|
|Outline|Dex (OIDC login for Outline)| 172.20.7.52| <http://localhost:5556/dex/.well-known/openid-configuration>|
|Outline|Outline| 172.20.7.53| <http://localhost:3002/>|
|Structurizr|Structurizr (local)| 172.20.7.60| <http://localhost:8112/>|
|Kroki|Kroki| 172.20.7.70| <http://localhost:8000/>|
|Kroki|Kroki Mermaid| 172.20.7.71| - (internal)|
|Kroki|Kroki BPMN| 172.20.7.72| - (internal)|
|Kroki|Kroki Excalidraw| 172.20.7.73| - (internal)|
|DrawIo|draw.io| 172.20.7.80| <http://localhost:8111/?offline=1>|
|ApiDocs|Swagger UI| 172.20.7.90| <http://localhost:8113/>|
|ApiDocs|Redoc| 172.20.7.91| <http://localhost:8114/>|

## Email (172.20.8.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Mailpit|Mailpit| 172.20.8.10| <http://localhost:8025/>|
|Smtp4dev|smtp4dev| 172.20.8.20| <http://localhost:8115/>|

## IaC (172.20.9.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Terraform|Terraform| 172.20.9.10| - (internal)|
|OpenTofu|OpenTofu| 172.20.9.20| - (internal)|
|Atlantis|Atlantis setup (one-shot)| 172.20.9.30| - (one-shot)|
|Atlantis|Atlantis| 172.20.9.31| <http://localhost:4141/>|
|Semaphore|Semaphore DB setup (one-shot)| 172.20.9.40| - (one-shot)|
|Semaphore|Semaphore UI| 172.20.9.41| <http://localhost:3004/>|

## Messaging (172.20.10.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Kafka|Kafka| 172.20.10.10| `kafka://localhost:9092`|
|Kafka|Kafka UI| 172.20.10.11| <http://localhost:8084/>|
|RabbitMQ|RabbitMQ| 172.20.10.20| <http://localhost:15672/>|
|NATS|NATS (JetStream)| 172.20.10.30| <http://localhost:8222/>|
|Mosquitto|Mosquitto (MQTT)| 172.20.10.40| `mqtt://localhost:1883`|
|Artemis|Apache Artemis| 172.20.10.50| <http://localhost:8161/console>|
|Redpanda|Redpanda| 172.20.10.60| `kafka://localhost:19092`|
|Redpanda|Redpanda Console| 172.20.10.61| <http://localhost:8116/>|
|Pulsar|Apache Pulsar (standalone)| 172.20.10.70| <http://localhost:8117/admin/v2/clusters>|
|Debezium|Debezium (Kafka Connect)| 172.20.10.80| <http://localhost:8118/connectors>|
|Apicurio|Apicurio DB setup (one-shot)| 172.20.10.90| - (one-shot)|
|Apicurio|Apicurio Registry| 172.20.10.91| <http://localhost:8119/>|
|Apicurio|Apicurio Registry UI| 172.20.10.92| <http://localhost:8120/>|

## Observability (172.20.11.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|AspireDashboard|Aspire Dashboard| 172.20.11.10| <http://localhost:18888/>|
|OpenTelemetry|OpenTelemetry Collector| 172.20.11.20| <http://localhost:4318/>|
|OpenTelemetry|Tempo| 172.20.11.21| <http://localhost:3200/ready>|
|OpenTelemetry|Loki| 172.20.11.22| <http://localhost:3100/ready>|
|Prometheus|Prometheus| 172.20.11.30| <http://localhost:9090/>|
|Prometheus|Prometheus Node Exporter| 172.20.11.31| <http://localhost:9100/metrics>|
|Prometheus|Prometheus Alertmanager| 172.20.11.32| <http://localhost:9093/>|
|Jaeger|Jaeger v2| 172.20.11.40| <http://localhost:16686/>|
|Pyroscope|Grafana Pyroscope| 172.20.11.50| <http://localhost:4041/>|
|UptimeKuma|Uptime Kuma| 172.20.11.60| <http://localhost:3005/>|
|cAdvisor|cAdvisor| 172.20.11.70| <http://localhost:8121/>|
|OtelLgtm|grafana/otel-lgtm| 172.20.11.80| <http://localhost:3006/>|
|SigNoz|SigNoz DB setup (one-shot)| 172.20.11.90| - (one-shot)|
|SigNoz|SigNoz ClickHouse Keeper| 172.20.11.91| - (internal)|
|SigNoz|SigNoz ClickHouse UDF setup (one-shot)| 172.20.11.92| - (one-shot)|
|SigNoz|SigNoz ClickHouse| 172.20.11.93| - (internal)|
|SigNoz|SigNoz schema migrator (one-shot)| 172.20.11.94| - (one-shot)|
|SigNoz|SigNoz| 172.20.11.95| <http://localhost:8122/>|
|SigNoz|SigNoz collector| 172.20.11.96| <http://localhost:34318/>|

## Orchestration (172.20.12.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Kubernetes| *(no compose stack - block .10-.19 reserved)*| |
|Portainer|Portainer| 172.20.12.20| <https://localhost:9443/>|
|Rancher|Rancher| 172.20.12.30| <https://localhost:8444/>|
|K3s|K3s (Kubernetes) + Argo CD| 172.20.12.40| <http://localhost:8124/>|
|K3s|K3s setup (one-shot: kubeconfig, DNS, Argo CD)| 172.20.12.41| - (one-shot)|
|Headlamp|Headlamp| 172.20.12.50| <http://localhost:4466/>|
|Nomad|HashiCorp Nomad| 172.20.12.60| <http://localhost:4646/ui/>|

## Packages (172.20.13.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Proget|ProGet| 172.20.13.10| <http://localhost:8091/>|
|Nexus|Sonatype Nexus CE| 172.20.13.20| <http://localhost:8125/>|
|Nexus|Nexus setup (one-shot)| 172.20.13.21| - (one-shot)|
|BaGetter|BaGetter| 172.20.13.30| <http://localhost:5555/>|
|Verdaccio|Verdaccio| 172.20.13.40| <http://localhost:4873/>|

## RP-LB (172.20.14.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|HAProxy|HAProxy| 172.20.14.10| <http://localhost:8100/>|
|NginxProxyManager|Nginx Proxy Manager| 172.20.14.20| <http://localhost:81/>|
|Traefik|Traefik| 172.20.14.30| <http://localhost:8126/web/>|
|Caddy|Caddy| 172.20.14.40| <http://localhost:8128/>|
|Yarp|YARP (.NET reverse proxy)| 172.20.14.50| <http://localhost:8129/web/>|
|Envoy|Envoy| 172.20.14.60| <http://localhost:8130/>|
|Kong|Kong Gateway (OSS, DB-less)| 172.20.14.70| <http://localhost:8131/web/>|

## Scheduling (172.20.15.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Hangfire|Hangfire| 172.20.15.10| <http://localhost:5010/hangfire>|
|Temporal|Temporal database setup (one-shot)| 172.20.15.20| - (one-shot)|
|Temporal|Temporal schema setup (one-shot)| 172.20.15.21| - (one-shot)|
|Temporal|Temporal server| 172.20.15.22| `grpc://localhost:7233`|
|Temporal|Temporal namespace setup (one-shot)| 172.20.15.23| - (one-shot)|
|Temporal|Temporal UI| 172.20.15.24| <http://localhost:8135/>|
|Airflow|Airflow database setup (one-shot)| 172.20.15.30| - (one-shot)|
|Airflow|Airflow init (one-shot)| 172.20.15.31| - (one-shot)|
|Airflow|Airflow API server| 172.20.15.32| <http://localhost:8136/>|
|Airflow|Airflow scheduler| 172.20.15.33| - (internal)|
|Airflow|Airflow DAG processor| 172.20.15.34| - (internal)|
|Airflow|Airflow triggerer| 172.20.15.35| - (internal)|
|Rundeck|Rundeck database setup (one-shot)| 172.20.15.40| - (one-shot)|
|Rundeck|Rundeck| 172.20.15.41| <http://localhost:4440/>|
|N8n|n8n database setup (one-shot)| 172.20.15.50| - (one-shot)|
|N8n|n8n| 172.20.15.51| <http://localhost:5678/>|
|N8n|n8n owner setup (one-shot)| 172.20.15.52| - (one-shot)|
|N8n|n8n task runners| 172.20.15.53| - (internal)|
|Camunda|Camunda 8 Orchestration Cluster| 172.20.15.60| <http://localhost:8152/operate>|
|Camunda|Camunda 8 Connectors| 172.20.15.61| <http://localhost:8153/actuator/health>|
|NodeRed|Node-RED| 172.20.15.70| <http://localhost:1880/>|

## Search (172.20.16.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|ElasticSearch|Elasticsearch setup (one-shot)| 172.20.16.10| - (one-shot)|
|ElasticSearch|Elasticsearch (es01)| 172.20.16.11| <https://localhost:9200/>|
|ElasticSearch|Kibana| 172.20.16.12| <http://localhost:5601/>|
|ElasticSearch|Metricbeat| 172.20.16.13| - (internal)|
|ElasticSearch|Filebeat| 172.20.16.14| - (internal)|
|ElasticSearch|Logstash| 172.20.16.15| - (internal)|
|OpenSearch|OpenSearch node 1| 172.20.16.20| <https://localhost:9201/>|
|OpenSearch|OpenSearch node 2| 172.20.16.21| - (internal)|
|OpenSearch|OpenSearch Dashboards| 172.20.16.22| <http://localhost:5602/>|
|Meilisearch|Meilisearch| 172.20.16.30| <http://localhost:7700/>|
|Typesense|Typesense| 172.20.16.40| <http://localhost:8137/health>|
|Solr|Apache Solr| 172.20.16.50| <http://localhost:8983/solr/>|

## Security (172.20.17.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Vault|Vault| 172.20.17.10| <http://localhost:8200/ui>|
|OpenBao|OpenBao| 172.20.17.20| <http://localhost:8202/ui>|
|StepCa|step-ca| 172.20.17.30| <https://localhost:9003/health>|
|Zap|ZAP (headless proxy + API)| 172.20.17.40| <http://localhost:8140/>|
|Zap|ZAP desktop UI (profile "ui")| 172.20.17.41| <http://localhost:8139/zap/>|
|Infisical|Infisical database setup (one-shot)| 172.20.17.50| - (one-shot)|
|Infisical|Infisical| 172.20.17.51| <http://localhost:8138/>|
|Infisical|Infisical admin setup (one-shot)| 172.20.17.52| - (one-shot)|

## SIEM (172.20.18.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Wazuh|Wazuh certs generator (one-shot)| 172.20.18.10| - (one-shot)|
|Wazuh|Wazuh Manager| 172.20.18.11| <https://localhost:55000/>|
|Wazuh|Wazuh Indexer| 172.20.18.12| <https://localhost:9202/>|
|Wazuh|Wazuh Dashboard| 172.20.18.13| <https://localhost:5603/>|
|Graylog|Graylog MongoDB| 172.20.18.20| - (internal)|
|Graylog|Graylog Data Node| 172.20.18.21| - (internal)|
|Graylog|Graylog| 172.20.18.22| <http://localhost:9004/>|

## SourceControl (172.20.19.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Gitea|Gitea| 172.20.19.10| <http://localhost:3001/>|
|Gitea|Gitea Actions runner| 172.20.19.11| - (internal)|
|Forgejo|Forgejo| 172.20.19.20| <http://localhost:3007/>|
|Forgejo|Forgejo admin + runner token setup (one-shot)| 172.20.19.21| - (one-shot)|
|Forgejo|Forgejo Actions runner| 172.20.19.22| - (internal)|
|GitLab|GitLab CE| 172.20.19.30| <http://localhost:8141/>|
|OneDev|OneDev| 172.20.19.40| <http://localhost:6610/>|

## Visualization (172.20.20.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Grafana|Grafana| 172.20.20.10| <http://localhost:3000/>|
|Metabase|Metabase database setup (one-shot)| 172.20.20.20| - (one-shot)|
|Metabase|Metabase| 172.20.20.21| <http://localhost:3008/>|
|Metabase|Metabase admin setup (one-shot)| 172.20.20.22| - (one-shot)|
|Superset|Superset database setup (one-shot)| 172.20.20.30| - (one-shot)|
|Superset|Superset init (one-shot)| 172.20.20.31| - (one-shot)|
|Superset|Superset| 172.20.20.32| <http://localhost:8142/>|
|Redash|Redash database setup (one-shot)| 172.20.20.40| - (one-shot)|
|Redash|Redash init (one-shot)| 172.20.20.41| - (one-shot)|
|Redash|Redash server| 172.20.20.42| <http://localhost:8143/>|
|Redash|Redash scheduler| 172.20.20.43| - (internal)|
|Redash|Redash worker| 172.20.20.44| - (internal)|

## WebServers (172.20.21.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Apache|Apache| 172.20.21.10| <http://localhost:8083/>|
|Nginx|Nginx| 172.20.21.20| <http://localhost:8180/>|
|Nginx|Nginx UI| 172.20.21.21| <http://localhost:8181/>|

## CI-CD (172.20.22.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Jenkins|Jenkins| 172.20.22.10| <http://localhost:8144/>|
|TeamCity|TeamCity server| 172.20.22.20| <http://localhost:8145/>|
|TeamCity|TeamCity build agent| 172.20.22.21| - (internal)|
|Woodpecker|Woodpecker Gitea OAuth2 setup (one-shot)| 172.20.22.30| - (one-shot)|
|Woodpecker|Woodpecker server| 172.20.22.31| <http://localhost:8146/>|
|Woodpecker|Woodpecker agent| 172.20.22.32| - (internal)|

## Testing (172.20.23.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|WireMock|WireMock| 172.20.23.10| <http://localhost:8147/>|
|Microcks|Microcks (uber)| 172.20.23.20| <http://localhost:8148/>|
|Microcks|Microcks artifact import (one-shot)| 172.20.23.21| - (one-shot)|
|Mockoon|Mockoon CLI| 172.20.23.30| <http://localhost:3009/>|
|K6|k6 (one-shot test run)| 172.20.23.40| - (one-shot)|
|Toxiproxy|Toxiproxy| 172.20.23.50| <http://localhost:8474/>|
|SeleniumGrid|Selenium hub| 172.20.23.60| <http://localhost:4447/>|
|SeleniumGrid|Selenium Chrome node| 172.20.23.61| <http://localhost:7900/>|
|SeleniumGrid|Selenium Firefox node| 172.20.23.62| <http://localhost:7901/>|
|SeleniumGrid|Selenium Edge node| 172.20.23.63| <http://localhost:7902/>|
|PactBroker|Pact Broker database setup (one-shot)| 172.20.23.70| - (one-shot)|
|PactBroker|Pact Broker| 172.20.23.71| <http://localhost:9292/>|
|Hoppscotch|Hoppscotch database setup (one-shot)| 172.20.23.80| - (one-shot)|
|Hoppscotch|Hoppscotch migrations (one-shot)| 172.20.23.81| - (one-shot)|
|Hoppscotch|Hoppscotch| 172.20.23.82| <http://localhost:3010/>|
|Hoppscotch|Hoppscotch onboarding (one-shot)| 172.20.23.83| - (one-shot)|

## FeatureFlags (172.20.24.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Unleash|Unleash database setup (one-shot)| 172.20.24.10| - (one-shot)|
|Unleash|Unleash| 172.20.24.11| <http://localhost:4242/>|
|Flagsmith|Flagsmith database setup (one-shot)| 172.20.24.20| - (one-shot)|
|Flagsmith|Flagsmith| 172.20.24.21| <http://localhost:8149/>|
|Flagsmith|Flagsmith admin + environments setup (one-shot)| 172.20.24.22| - (one-shot)|
|GrowthBook|GrowthBook MongoDB 8.0| 172.20.24.30| - (internal)|
|GrowthBook|GrowthBook| 172.20.24.31| <http://localhost:3011/>|
|GrowthBook|GrowthBook first-time setup (one-shot)| 172.20.24.32| - (one-shot)|
|Flagd|flagd| 172.20.24.40| <http://localhost:8016/ofrep/v1/evaluate/flags>|
|Consul|Consul server| 172.20.24.50| <http://localhost:8500/ui/>|
|Consul|Consul KV seed (one-shot)| 172.20.24.51| - (one-shot)|

## ObjectStorage (172.20.25.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|RustFS|RustFS| 172.20.25.10| <http://localhost:9009/rustfs/console/>|
|RustFS|RustFS bucket setup (one-shot)| 172.20.25.11| - (one-shot)|
|SeaweedFS|SeaweedFS (weed mini)| 172.20.25.20| <http://localhost:12535/>|
|Garage|Garage| 172.20.25.30| <http://localhost:3900/>|
|Garage|Garage layout/key/bucket setup (one-shot)| 172.20.25.31| - (one-shot)|
|Garage|Garage web UI| 172.20.25.32| <http://localhost:3909/>|

## ServiceMesh (172.20.26.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Dapr|Dapr placement| 172.20.26.10| `grpc://localhost:50005`|
|Dapr|Dapr scheduler| 172.20.26.11| `grpc://localhost:50006`|
|Dapr|Dapr dashboard| 172.20.26.12| <http://localhost:8151/>|
|Dapr|Dapr sidecar (daprd for an app on the host)| 172.20.26.20| <http://localhost:3500/v1.0/healthz>|

## AI (172.20.27.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Ollama|Ollama| 172.20.27.10| <http://localhost:11434/api/tags>|
|Ollama|Ollama model pull (one-shot)| 172.20.27.11| - (one-shot)|
|OpenWebUI|Open WebUI| 172.20.27.20| <http://localhost:3013/>|
|LiteLLM|LiteLLM database setup (one-shot)| 172.20.27.30| - (one-shot)|
|LiteLLM|LiteLLM proxy| 172.20.27.31| <http://localhost:4000/ui>|
|Langfuse|Langfuse database setup (one-shot)| 172.20.27.40| - (one-shot)|
|Langfuse|Langfuse S3 bucket setup (one-shot)| 172.20.27.41| - (one-shot)|
|Langfuse|Langfuse ClickHouse| 172.20.27.42| - (internal)|
|Langfuse|Langfuse web| 172.20.27.43| <http://localhost:3014/>|
|Langfuse|Langfuse worker| 172.20.27.44| - (internal)|

## DataIntegration (172.20.28.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|NiFi|Apache NiFi| 172.20.28.10| <https://localhost:8155/nifi>|
|NiFi|NiFi conf setup (one-shot)| 172.20.28.11| - (one-shot)|
|Airbyte|Airbyte database setup (one-shot)| 172.20.28.20| - (one-shot)|
|Airbyte|Airbyte Helm install into K3s (one-shot)| 172.20.28.21| - (one-shot)|
|Airbyte|Airbyte proxy (localhost:8154 -> K3s NodePort 30081)| 172.20.28.22| <http://localhost:8154/>|

## Collaboration (172.20.29.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Mattermost|Mattermost database setup (one-shot)| 172.20.29.10| - (one-shot)|
|Mattermost|Mattermost| 172.20.29.11| <http://localhost:8065/>|
|Mattermost|Mattermost admin/team setup (one-shot)| 172.20.29.12| - (one-shot)|
|RocketChat|Rocket.Chat MongoDB (replica set)| 172.20.29.20| - (internal)|
|RocketChat|Rocket.Chat replica set init (one-shot)| 172.20.29.21| - (one-shot)|
|RocketChat|Rocket.Chat| 172.20.29.22| <http://localhost:3015/>|
|Plane|Plane database setup (one-shot)| 172.20.29.30| - (one-shot)|
|Plane|Plane S3 store (RustFS)| 172.20.29.31| - (internal)|
|Plane|Plane migrator (one-shot)| 172.20.29.32| - (one-shot)|
|Plane|Plane API| 172.20.29.33| - (internal)|
|Plane|Plane worker| 172.20.29.34| - (internal)|
|Plane|Plane beat worker| 172.20.29.35| - (internal)|
|Plane|Plane web| 172.20.29.36| - (internal)|
|Plane|Plane space| 172.20.29.37| - (internal)|
|Plane|Plane admin (god mode)| 172.20.29.38| - (internal)|
|Plane|Plane live| 172.20.29.39| - (internal)|
|Plane|Plane proxy| 172.20.29.40| <http://localhost:8156/>|
|Plane|Plane admin setup (one-shot)| 172.20.29.41| - (one-shot)|
|Plane|Plane RabbitMQ broker| 172.20.29.42| - (internal)|

## DevTools (172.20.30.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Homepage|Homepage| 172.20.30.10| <http://localhost:3016/>|
|Homarr|Homarr| 172.20.30.20| <http://localhost:7575/>|
|Homarr|Homarr admin/onboarding setup (one-shot)| 172.20.30.21| - (one-shot)|
|ITTools|IT-Tools| 172.20.30.30| <http://localhost:8157/>|
|CyberChef|CyberChef| 172.20.30.40| <http://localhost:8158/>|
|CodeServer|code-server (.NET SDK)| 172.20.30.50| <http://localhost:8159/>|
