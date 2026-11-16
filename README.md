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
Tempo/Loki, Elasticsearch, OpenSearch, SonarQube, pgAdmin, Vault, Kafka, Spark, Oracle, EventStoreDB, Wazuh), using `sudo`.
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

## Analytics (172.20.1.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Apache Spark|Apache Spark (master)| 172.20.1.10|
|Apache Spark|Apache Spark Worker| 172.20.1.11|
|Seq|Seq| 172.20.1.20|

## Authentication (172.20.2.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Keycloak|Keycloak| 172.20.2.10|
|Supertokens|SuperTokens| 172.20.2.20|

## CloudEmulators (172.20.3.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|AzureCosmosDb|Azure Cosmos DB emulator| 172.20.3.10|
|AzureServiceBus|Azure Service Bus emulator| 172.20.3.20|
|Azurite|Azurite| 172.20.3.30|

## CodeAnalysis (172.20.4.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Sonarqube|SonarQube| 172.20.4.10|

## Containerization (172.20.5.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|DockerRegistry|Docker Registry| 172.20.5.10|
|DockerRegistry|Docker Registry UI| 172.20.5.11|

## Databases (172.20.6.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|ApacheCassandra|Apache Cassandra| 172.20.6.10|
|ClickHouse|ClickHouse| 172.20.6.20|
|CockroachDB|CockroachDB| 172.20.6.30|
|EventStoreDb|EventStoreDB| 172.20.6.40|
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
|PostgreSQL|PostgreSQL| 172.20.6.130|
|PostgreSQL|pgAdmin4| 172.20.6.131|
|Prometheus|Prometheus| 172.20.6.140|
|Prometheus|Prometheus Node Exporter| 172.20.6.141|
|Prometheus|Prometheus Alertmanager| 172.20.6.142|
|Redis|Redis| 172.20.6.150|

## Documentation (172.20.7.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Backstage|Backstage| 172.20.7.10|
|Mediawiki|MediaWiki| 172.20.7.20|

## Email (172.20.8.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Mailpit|Mailpit| 172.20.8.10|

## IaC (172.20.9.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Terraform|Terraform| 172.20.9.10|
|Terraform|Gaia| 172.20.9.11|
|Terraform|Gaia runner| 172.20.9.12|
|Terraform|Gaia MongoDB| 172.20.9.13|

## Messaging (172.20.10.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Kafka|Kafka| 172.20.10.10|
|Kafka|Kafka UI| 172.20.10.11|
|RabbitMQ|RabbitMQ| 172.20.10.20|

## Observability (172.20.11.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|AspireDashboard|Aspire Dashboard| 172.20.11.10|
|OpenTelemetry|OpenTelemetry Collector| 172.20.11.20|
|OpenTelemetry|Tempo| 172.20.11.21|
|OpenTelemetry|Loki| 172.20.11.22|

## Orchestration (172.20.12.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Kubernetes| *(no compose stack - block .10-.19 reserved)*| |
|Portainer|Portainer| 172.20.12.20|
|Rancher|Rancher| 172.20.12.30|

## Packages (172.20.13.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Proget|ProGet| 172.20.13.10|

## RP-LB (172.20.14.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|HAProxy|HAProxy| 172.20.14.10|
|NginxProxyManager|Nginx Proxy Manager| 172.20.14.20|

## Scheduling (172.20.15.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Hangfire|Hangfire| 172.20.15.10|

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

## Security (172.20.17.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Vault|Vault| 172.20.17.10|

## SIEM (172.20.18.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Wazuh|Wazuh certs generator (one-shot)| 172.20.18.10|
|Wazuh|Wazuh Manager| 172.20.18.11|
|Wazuh|Wazuh Indexer| 172.20.18.12|
|Wazuh|Wazuh Dashboard| 172.20.18.13|

## SourceControl (172.20.19.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Gitea|Gitea| 172.20.19.10|
|Gitea|Gitea Actions runner| 172.20.19.11|

## Visualization (172.20.20.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Grafana|Grafana| 172.20.20.10|

## WebServers (172.20.21.x)
|Folder|Name|IP Address|
|:----------|:----------|:----------|
|Apache|Apache| 172.20.21.10|
|Nginx|Nginx| 172.20.21.20|
|Nginx|Nginx UI| 172.20.21.21|
