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

## Analytics (172.20.1.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Apache Spark|Apache Spark (master)| 172.20.1.10|
|Apache Spark|Apache Spark Worker| 172.20.1.11|
|Seq|Seq| 172.20.1.20|
|ApacheFlink|Flink JobManager| 172.20.1.30|
|ApacheFlink|Flink TaskManager| 172.20.1.31|
|Trino|Trino| 172.20.1.40|
|JupyterLab|JupyterLab| 172.20.1.50|

## Authentication (172.20.2.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Keycloak|Keycloak| 172.20.2.10|
|Supertokens|SuperTokens| 172.20.2.20|
|Authentik|authentik DB setup (one-shot)| 172.20.2.30|
|Authentik|authentik server| 172.20.2.31|
|Authentik|authentik worker| 172.20.2.32|
|Zitadel|ZITADEL DB setup (one-shot)| 172.20.2.40|
|Zitadel|ZITADEL + Login UI (shared network)| 172.20.2.41|
|Authelia|Authelia cert/key setup (one-shot)| 172.20.2.50|
|Authelia|Authelia| 172.20.2.51|
|Ory|Ory DB setup (one-shot)| 172.20.2.60|
|Ory|Kratos migrations (one-shot)| 172.20.2.61|
|Ory|Kratos| 172.20.2.62|
|Ory|Hydra migrations (one-shot)| 172.20.2.63|
|Ory|Hydra| 172.20.2.64|
|Ory|Kratos self-service UI| 172.20.2.65|

## CloudEmulators (172.20.3.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|AzureCosmosDb|Azure Cosmos DB emulator| 172.20.3.10|
|AzureServiceBus|Azure Service Bus emulator| 172.20.3.20|
|Azurite|Azurite| 172.20.3.30|
|AzureEventHubs|Azure Event Hubs emulator| 172.20.3.40|
|Floci|Floci (AWS emulator)| 172.20.3.50|
|LocalStack|LocalStack (AWS emulator, auth token)| 172.20.3.60|
|GcpPubSub|Google Cloud Pub/Sub emulator| 172.20.3.70|
|GcpFirestore|Google Cloud Firestore emulator| 172.20.3.80|
|GcpSpanner|Google Cloud Spanner emulator| 172.20.3.90|
|LowkeyVault|Lowkey Vault (Azure Key Vault emulator)| 172.20.3.100|

## CodeAnalysis (172.20.4.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Sonarqube|SonarQube| 172.20.4.10|
|DependencyTrack|Dependency-Track DB setup (one-shot)| 172.20.4.20|
|DependencyTrack|Dependency-Track API server| 172.20.4.21|
|DependencyTrack|Dependency-Track frontend| 172.20.4.22|
|Trivy|Trivy server| 172.20.4.30|
|DefectDojo|DefectDojo DB setup (one-shot)| 172.20.4.40|
|DefectDojo|DefectDojo initializer (one-shot)| 172.20.4.41|
|DefectDojo|DefectDojo uWSGI| 172.20.4.42|
|DefectDojo|DefectDojo Celery beat| 172.20.4.43|
|DefectDojo|DefectDojo Celery worker| 172.20.4.44|
|DefectDojo|DefectDojo nginx| 172.20.4.45|
|DefectDojo|DefectDojo Valkey| 172.20.4.46|

## Containerization (172.20.5.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|DockerRegistry|Docker Registry| 172.20.5.10|
|DockerRegistry|Docker Registry UI| 172.20.5.11|
|Dozzle|Dozzle| 172.20.5.20|
|Zot|zot registry| 172.20.5.30|
|Harbor|Harbor DB setup (one-shot)| 172.20.5.40|
|Harbor|Harbor key/config setup (one-shot)| 172.20.5.41|
|Harbor|Harbor registry| 172.20.5.42|
|Harbor|Harbor registryctl| 172.20.5.43|
|Harbor|Harbor core| 172.20.5.44|
|Harbor|Harbor portal| 172.20.5.45|
|Harbor|Harbor jobservice| 172.20.5.46|
|Harbor|Harbor Redis (Valkey)| 172.20.5.47|
|Harbor|Harbor proxy (nginx)| 172.20.5.48|
|Harbor|Harbor Trivy adapter| 172.20.5.49|

## Databases (172.20.6.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|ApacheCassandra|Apache Cassandra| 172.20.6.10|
|ClickHouse|ClickHouse| 172.20.6.20|
|CockroachDB|CockroachDB| 172.20.6.30|
|KurrentDB|KurrentDB (formerly EventStoreDB)| 172.20.6.40|
|InfluxDb|InfluxDB| 172.20.6.50|
|MariaDb|MariaDB| 172.20.6.60|
|MariaDb|Adminer| 172.20.6.61|
|Milvus|Milvus etcd| 172.20.6.70|
|Milvus|Milvus MinIO| 172.20.6.71|
|Milvus|Milvus| 172.20.6.72|
|MongoDB|MongoDB| 172.20.6.80|
|MongoDB|Mongo Express| 172.20.6.81|
|MSSQL|MSSQL| 172.20.6.90|
|MySQL|MySQL| 172.20.6.100|
|MySQL|phpMyAdmin| 172.20.6.101|
|Neo4J|Neo4j| 172.20.6.110|
|Oracle|Oracle| 172.20.6.120|
|PostgreSQL|PostgreSQL (with pgvector)| 172.20.6.130|
|PostgreSQL|pgAdmin4| 172.20.6.131|
| *(.140-.149 free: Prometheus moved to Observability)*| | |
|Redis|Redis| 172.20.6.150|
|RavenDB|RavenDB| 172.20.6.160|
|CouchDB|CouchDB| 172.20.6.170|
|CouchDB|CouchDB setup (one-shot)| 172.20.6.171|
|Couchbase|Couchbase Server CE| 172.20.6.180|
|Couchbase|Couchbase setup (one-shot)| 172.20.6.181|
|Garnet|Garnet| 172.20.6.190|
|Memcached|Memcached| 172.20.6.200|
|Qdrant|Qdrant| 172.20.6.210|
|ScyllaDB|ScyllaDB| 172.20.6.220|
|CloudBeaver|CloudBeaver| 172.20.6.230|
|TimescaleDB|TimescaleDB| 172.20.6.240|
|Valkey|Valkey| 172.20.6.250|

## Documentation (172.20.7.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Backstage|Backstage| 172.20.7.10|
|Mediawiki|MediaWiki| 172.20.7.20|
|WikiJs|Wiki.js DB setup (one-shot)| 172.20.7.30|
|WikiJs|Wiki.js| 172.20.7.31|
|BookStack|BookStack DB setup (one-shot)| 172.20.7.40|
|BookStack|BookStack| 172.20.7.41|
|Outline|Outline DB setup (one-shot)| 172.20.7.50|
|Outline|Outline Redis| 172.20.7.51|
|Outline|Dex (OIDC login for Outline)| 172.20.7.52|
|Outline|Outline| 172.20.7.53|
|Structurizr|Structurizr (local)| 172.20.7.60|
|Kroki|Kroki| 172.20.7.70|
|Kroki|Kroki Mermaid| 172.20.7.71|
|Kroki|Kroki BPMN| 172.20.7.72|
|Kroki|Kroki Excalidraw| 172.20.7.73|
|DrawIo|draw.io| 172.20.7.80|
|ApiDocs|Swagger UI| 172.20.7.90|
|ApiDocs|Redoc| 172.20.7.91|

## Email (172.20.8.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Mailpit|Mailpit| 172.20.8.10|
|Smtp4dev|smtp4dev| 172.20.8.20|

## IaC (172.20.9.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Terraform|Terraform| 172.20.9.10|
|OpenTofu|OpenTofu| 172.20.9.20|
|Atlantis|Atlantis setup (one-shot)| 172.20.9.30|
|Atlantis|Atlantis| 172.20.9.31|
|Semaphore|Semaphore DB setup (one-shot)| 172.20.9.40|
|Semaphore|Semaphore UI| 172.20.9.41|

## Messaging (172.20.10.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Kafka|Kafka| 172.20.10.10|
|Kafka|Kafka UI| 172.20.10.11|
|RabbitMQ|RabbitMQ| 172.20.10.20|
|NATS|NATS (JetStream)| 172.20.10.30|
|Mosquitto|Mosquitto (MQTT)| 172.20.10.40|
|Artemis|Apache Artemis| 172.20.10.50|
|Redpanda|Redpanda| 172.20.10.60|
|Redpanda|Redpanda Console| 172.20.10.61|
|Pulsar|Apache Pulsar (standalone)| 172.20.10.70|
|Debezium|Debezium (Kafka Connect)| 172.20.10.80|
|Apicurio|Apicurio DB setup (one-shot)| 172.20.10.90|
|Apicurio|Apicurio Registry| 172.20.10.91|
|Apicurio|Apicurio Registry UI| 172.20.10.92|

## Observability (172.20.11.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|AspireDashboard|Aspire Dashboard| 172.20.11.10|
|OpenTelemetry|OpenTelemetry Collector| 172.20.11.20|
|OpenTelemetry|Tempo| 172.20.11.21|
|OpenTelemetry|Loki| 172.20.11.22|
|Prometheus|Prometheus| 172.20.11.30|
|Prometheus|Prometheus Node Exporter| 172.20.11.31|
|Prometheus|Prometheus Alertmanager| 172.20.11.32|
|Jaeger|Jaeger v2| 172.20.11.40|
|Pyroscope|Grafana Pyroscope| 172.20.11.50|
|UptimeKuma|Uptime Kuma| 172.20.11.60|
|cAdvisor|cAdvisor| 172.20.11.70|
|OtelLgtm|grafana/otel-lgtm| 172.20.11.80|
|SigNoz|SigNoz DB setup (one-shot)| 172.20.11.90|
|SigNoz|SigNoz ClickHouse Keeper| 172.20.11.91|
|SigNoz|SigNoz ClickHouse UDF setup (one-shot)| 172.20.11.92|
|SigNoz|SigNoz ClickHouse| 172.20.11.93|
|SigNoz|SigNoz schema migrator (one-shot)| 172.20.11.94|
|SigNoz|SigNoz| 172.20.11.95|
|SigNoz|SigNoz collector| 172.20.11.96|

## Orchestration (172.20.12.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Kubernetes| *(no compose stack - block .10-.19 reserved)*| |
|Portainer|Portainer| 172.20.12.20|
|Rancher|Rancher| 172.20.12.30|
|K3s|K3s (Kubernetes) + Argo CD| 172.20.12.40|
|K3s|K3s setup (one-shot: kubeconfig, DNS, Argo CD)| 172.20.12.41|
|Headlamp|Headlamp| 172.20.12.50|
|Nomad|HashiCorp Nomad| 172.20.12.60|

## Packages (172.20.13.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Proget|ProGet| 172.20.13.10|
|Nexus|Sonatype Nexus CE| 172.20.13.20|
|Nexus|Nexus setup (one-shot)| 172.20.13.21|
|BaGetter|BaGetter| 172.20.13.30|
|Verdaccio|Verdaccio| 172.20.13.40|

## RP-LB (172.20.14.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|HAProxy|HAProxy| 172.20.14.10|
|NginxProxyManager|Nginx Proxy Manager| 172.20.14.20|
|Traefik|Traefik| 172.20.14.30|
|Caddy|Caddy| 172.20.14.40|
|Yarp|YARP (.NET reverse proxy)| 172.20.14.50|
|Envoy|Envoy| 172.20.14.60|
|Kong|Kong Gateway (OSS, DB-less)| 172.20.14.70|

## Scheduling (172.20.15.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Hangfire|Hangfire| 172.20.15.10|
|Temporal|Temporal database setup (one-shot)| 172.20.15.20|
|Temporal|Temporal schema setup (one-shot)| 172.20.15.21|
|Temporal|Temporal server| 172.20.15.22|
|Temporal|Temporal namespace setup (one-shot)| 172.20.15.23|
|Temporal|Temporal UI| 172.20.15.24|
|Airflow|Airflow database setup (one-shot)| 172.20.15.30|
|Airflow|Airflow init (one-shot)| 172.20.15.31|
|Airflow|Airflow API server| 172.20.15.32|
|Airflow|Airflow scheduler| 172.20.15.33|
|Airflow|Airflow DAG processor| 172.20.15.34|
|Airflow|Airflow triggerer| 172.20.15.35|
|Rundeck|Rundeck database setup (one-shot)| 172.20.15.40|
|Rundeck|Rundeck| 172.20.15.41|
|N8n|n8n database setup (one-shot)| 172.20.15.50|
|N8n|n8n| 172.20.15.51|
|N8n|n8n owner setup (one-shot)| 172.20.15.52|
|N8n|n8n task runners| 172.20.15.53|
|Camunda|Camunda 8 Orchestration Cluster| 172.20.15.60|
|Camunda|Camunda 8 Connectors| 172.20.15.61|
|NodeRed|Node-RED| 172.20.15.70|

## Search (172.20.16.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|ElasticSearch|Elasticsearch setup (one-shot)| 172.20.16.10|
|ElasticSearch|Elasticsearch (es01)| 172.20.16.11|
|ElasticSearch|Kibana| 172.20.16.12|
|ElasticSearch|Metricbeat| 172.20.16.13|
|ElasticSearch|Filebeat| 172.20.16.14|
|ElasticSearch|Logstash| 172.20.16.15|
|OpenSearch|OpenSearch node 1| 172.20.16.20|
|OpenSearch|OpenSearch node 2| 172.20.16.21|
|OpenSearch|OpenSearch Dashboards| 172.20.16.22|
|Meilisearch|Meilisearch| 172.20.16.30|
|Typesense|Typesense| 172.20.16.40|
|Solr|Apache Solr| 172.20.16.50|

## Security (172.20.17.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Vault|Vault| 172.20.17.10|
|OpenBao|OpenBao| 172.20.17.20|
|StepCa|step-ca| 172.20.17.30|
|Zap|ZAP (headless proxy + API)| 172.20.17.40|
|Zap|ZAP desktop UI (profile "ui")| 172.20.17.41|
|Infisical|Infisical database setup (one-shot)| 172.20.17.50|
|Infisical|Infisical| 172.20.17.51|
|Infisical|Infisical admin setup (one-shot)| 172.20.17.52|

## SIEM (172.20.18.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Wazuh|Wazuh certs generator (one-shot)| 172.20.18.10|
|Wazuh|Wazuh Manager| 172.20.18.11|
|Wazuh|Wazuh Indexer| 172.20.18.12|
|Wazuh|Wazuh Dashboard| 172.20.18.13|
|Graylog|Graylog MongoDB| 172.20.18.20|
|Graylog|Graylog Data Node| 172.20.18.21|
|Graylog|Graylog| 172.20.18.22|

## SourceControl (172.20.19.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Gitea|Gitea| 172.20.19.10|
|Gitea|Gitea Actions runner| 172.20.19.11|
|Forgejo|Forgejo| 172.20.19.20|
|Forgejo|Forgejo admin + runner token setup (one-shot)| 172.20.19.21|
|Forgejo|Forgejo Actions runner| 172.20.19.22|
|GitLab|GitLab CE| 172.20.19.30|
|OneDev|OneDev| 172.20.19.40|

## Visualization (172.20.20.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Grafana|Grafana| 172.20.20.10|
|Metabase|Metabase database setup (one-shot)| 172.20.20.20|
|Metabase|Metabase| 172.20.20.21|
|Metabase|Metabase admin setup (one-shot)| 172.20.20.22|
|Superset|Superset database setup (one-shot)| 172.20.20.30|
|Superset|Superset init (one-shot)| 172.20.20.31|
|Superset|Superset| 172.20.20.32|
|Redash|Redash database setup (one-shot)| 172.20.20.40|
|Redash|Redash init (one-shot)| 172.20.20.41|
|Redash|Redash server| 172.20.20.42|
|Redash|Redash scheduler| 172.20.20.43|
|Redash|Redash worker| 172.20.20.44|

## WebServers (172.20.21.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Apache|Apache| 172.20.21.10|
|Nginx|Nginx| 172.20.21.20|
|Nginx|Nginx UI| 172.20.21.21|

## CI-CD (172.20.22.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Jenkins|Jenkins| 172.20.22.10|
|TeamCity|TeamCity server| 172.20.22.20|
|TeamCity|TeamCity build agent| 172.20.22.21|
|Woodpecker|Woodpecker Gitea OAuth2 setup (one-shot)| 172.20.22.30|
|Woodpecker|Woodpecker server| 172.20.22.31|
|Woodpecker|Woodpecker agent| 172.20.22.32|

## Testing (172.20.23.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|WireMock|WireMock| 172.20.23.10|
|Microcks|Microcks (uber)| 172.20.23.20|
|Microcks|Microcks artifact import (one-shot)| 172.20.23.21|
|Mockoon|Mockoon CLI| 172.20.23.30|
|K6|k6 (one-shot test run)| 172.20.23.40|
|Toxiproxy|Toxiproxy| 172.20.23.50|
|SeleniumGrid|Selenium hub| 172.20.23.60|
|SeleniumGrid|Selenium Chrome node| 172.20.23.61|
|SeleniumGrid|Selenium Firefox node| 172.20.23.62|
|SeleniumGrid|Selenium Edge node| 172.20.23.63|
|PactBroker|Pact Broker database setup (one-shot)| 172.20.23.70|
|PactBroker|Pact Broker| 172.20.23.71|
|Hoppscotch|Hoppscotch database setup (one-shot)| 172.20.23.80|
|Hoppscotch|Hoppscotch migrations (one-shot)| 172.20.23.81|
|Hoppscotch|Hoppscotch| 172.20.23.82|
|Hoppscotch|Hoppscotch onboarding (one-shot)| 172.20.23.83|

## FeatureFlags (172.20.24.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Unleash|Unleash database setup (one-shot)| 172.20.24.10|
|Unleash|Unleash| 172.20.24.11|
|Flagsmith|Flagsmith database setup (one-shot)| 172.20.24.20|
|Flagsmith|Flagsmith| 172.20.24.21|
|Flagsmith|Flagsmith admin + environments setup (one-shot)| 172.20.24.22|
|GrowthBook|GrowthBook MongoDB 8.0| 172.20.24.30|
|GrowthBook|GrowthBook| 172.20.24.31|
|GrowthBook|GrowthBook first-time setup (one-shot)| 172.20.24.32|
|Flagd|flagd| 172.20.24.40|
|Consul|Consul server| 172.20.24.50|
|Consul|Consul KV seed (one-shot)| 172.20.24.51|

## ObjectStorage (172.20.25.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|RustFS|RustFS| 172.20.25.10|
|RustFS|RustFS bucket setup (one-shot)| 172.20.25.11|
|SeaweedFS|SeaweedFS (weed mini)| 172.20.25.20|
|Garage|Garage| 172.20.25.30|
|Garage|Garage layout/key/bucket setup (one-shot)| 172.20.25.31|
|Garage|Garage web UI| 172.20.25.32|

## ServiceMesh (172.20.26.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Dapr|Dapr placement| 172.20.26.10|
|Dapr|Dapr scheduler| 172.20.26.11|
|Dapr|Dapr dashboard| 172.20.26.12|
|Dapr|Dapr sidecar (daprd for an app on the host)| 172.20.26.20|

## AI (172.20.27.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Ollama|Ollama| 172.20.27.10|
|Ollama|Ollama model pull (one-shot)| 172.20.27.11|
|OpenWebUI|Open WebUI| 172.20.27.20|
|LiteLLM|LiteLLM database setup (one-shot)| 172.20.27.30|
|LiteLLM|LiteLLM proxy| 172.20.27.31|
|Langfuse|Langfuse database setup (one-shot)| 172.20.27.40|
|Langfuse|Langfuse S3 bucket setup (one-shot)| 172.20.27.41|
|Langfuse|Langfuse ClickHouse| 172.20.27.42|
|Langfuse|Langfuse web| 172.20.27.43|
|Langfuse|Langfuse worker| 172.20.27.44|

## DataIntegration (172.20.28.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|NiFi|Apache NiFi| 172.20.28.10|
|NiFi|NiFi conf setup (one-shot)| 172.20.28.11|
|Airbyte|Airbyte database setup (one-shot)| 172.20.28.20|
|Airbyte|Airbyte Helm install into K3s (one-shot)| 172.20.28.21|
|Airbyte|Airbyte proxy (localhost:8154 -> K3s NodePort 30081)| 172.20.28.22|

## Collaboration (172.20.29.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Mattermost|Mattermost database setup (one-shot)| 172.20.29.10|
|Mattermost|Mattermost| 172.20.29.11|
|Mattermost|Mattermost admin/team setup (one-shot)| 172.20.29.12|
|RocketChat|Rocket.Chat MongoDB (replica set)| 172.20.29.20|
|RocketChat|Rocket.Chat replica set init (one-shot)| 172.20.29.21|
|RocketChat|Rocket.Chat| 172.20.29.22|
|Plane|Plane database setup (one-shot)| 172.20.29.30|
|Plane|Plane S3 store (RustFS)| 172.20.29.31|
|Plane|Plane migrator (one-shot)| 172.20.29.32|
|Plane|Plane API| 172.20.29.33|
|Plane|Plane worker| 172.20.29.34|
|Plane|Plane beat worker| 172.20.29.35|
|Plane|Plane web| 172.20.29.36|
|Plane|Plane space| 172.20.29.37|
|Plane|Plane admin (god mode)| 172.20.29.38|
|Plane|Plane live| 172.20.29.39|
|Plane|Plane proxy| 172.20.29.40|
|Plane|Plane admin setup (one-shot)| 172.20.29.41|
|Plane|Plane RabbitMQ broker| 172.20.29.42|

## DevTools (172.20.30.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Homepage|Homepage| 172.20.30.10|
|Homarr|Homarr| 172.20.30.20|
|Homarr|Homarr admin/onboarding setup (one-shot)| 172.20.30.21|
|ITTools|IT-Tools| 172.20.30.30|
|CyberChef|CyberChef| 172.20.30.40|
|CodeServer|code-server (.NET SDK)| 172.20.30.50|
