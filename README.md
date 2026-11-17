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

**URL column:** the home page of the project each container runs. Setup containers (one-shot) link to the project they set up; bundled helpers (e.g. Adminer, Kibana, a stack's own MongoDB or ClickHouse) link to their own project. Host ports and local URLs are in each stack's `ReadMe.md` and the host-port map in `REVIEW.md`.

## Analytics (172.20.1.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Apache Spark|Apache Spark (master)| 172.20.1.10| <https://spark.apache.org/>|
|Apache Spark|Apache Spark Worker| 172.20.1.11| <https://spark.apache.org/>|
|Seq|Seq| 172.20.1.20| <https://datalust.co/seq>|
|ApacheFlink|Flink JobManager| 172.20.1.30| <https://flink.apache.org/>|
|ApacheFlink|Flink TaskManager| 172.20.1.31| <https://flink.apache.org/>|
|Trino|Trino| 172.20.1.40| <https://trino.io/>|
|JupyterLab|JupyterLab| 172.20.1.50| <https://jupyter.org/>|

## Authentication (172.20.2.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Keycloak|Keycloak| 172.20.2.10| <https://www.keycloak.org/>|
|Supertokens|SuperTokens| 172.20.2.20| <https://supertokens.com/>|
|Authentik|authentik DB setup (one-shot)| 172.20.2.30| <https://goauthentik.io/>|
|Authentik|authentik server| 172.20.2.31| <https://goauthentik.io/>|
|Authentik|authentik worker| 172.20.2.32| <https://goauthentik.io/>|
|Zitadel|ZITADEL DB setup (one-shot)| 172.20.2.40| <https://zitadel.com/>|
|Zitadel|ZITADEL + Login UI (shared network)| 172.20.2.41| <https://zitadel.com/>|
|Authelia|Authelia cert/key setup (one-shot)| 172.20.2.50| <https://www.authelia.com/>|
|Authelia|Authelia| 172.20.2.51| <https://www.authelia.com/>|
|Ory|Ory DB setup (one-shot)| 172.20.2.60| <https://www.ory.sh/>|
|Ory|Kratos migrations (one-shot)| 172.20.2.61| <https://www.ory.sh/kratos/>|
|Ory|Kratos| 172.20.2.62| <https://www.ory.sh/kratos/>|
|Ory|Hydra migrations (one-shot)| 172.20.2.63| <https://www.ory.sh/hydra/>|
|Ory|Hydra| 172.20.2.64| <https://www.ory.sh/hydra/>|
|Ory|Kratos self-service UI| 172.20.2.65| <https://github.com/ory/kratos-selfservice-ui-node>|

## CloudEmulators (172.20.3.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|AzureCosmosDb|Azure Cosmos DB emulator| 172.20.3.10| <https://learn.microsoft.com/en-us/azure/cosmos-db/emulator>|
|AzureServiceBus|Azure Service Bus emulator| 172.20.3.20| <https://learn.microsoft.com/en-us/azure/service-bus-messaging/overview-emulator>|
|Azurite|Azurite| 172.20.3.30| <https://github.com/Azure/Azurite>|
|AzureEventHubs|Azure Event Hubs emulator| 172.20.3.40| <https://learn.microsoft.com/en-us/azure/event-hubs/overview-emulator>|
|Floci|Floci (AWS emulator)| 172.20.3.50| <https://hub.docker.com/r/floci/floci>|
|LocalStack|LocalStack (AWS emulator, auth token)| 172.20.3.60| <https://www.localstack.cloud/>|
|GcpPubSub|Google Cloud Pub/Sub emulator| 172.20.3.70| <https://cloud.google.com/pubsub/docs/emulator>|
|GcpFirestore|Google Cloud Firestore emulator| 172.20.3.80| <https://cloud.google.com/firestore/docs/emulator>|
|GcpSpanner|Google Cloud Spanner emulator| 172.20.3.90| <https://cloud.google.com/spanner/docs/emulator>|
|LowkeyVault|Lowkey Vault (Azure Key Vault emulator)| 172.20.3.100| <https://github.com/nagyesta/lowkey-vault>|

## CodeAnalysis (172.20.4.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Sonarqube|SonarQube| 172.20.4.10| <https://www.sonarsource.com/products/sonarqube/>|
|DependencyTrack|Dependency-Track DB setup (one-shot)| 172.20.4.20| <https://dependencytrack.org/>|
|DependencyTrack|Dependency-Track API server| 172.20.4.21| <https://dependencytrack.org/>|
|DependencyTrack|Dependency-Track frontend| 172.20.4.22| <https://dependencytrack.org/>|
|Trivy|Trivy server| 172.20.4.30| <https://trivy.dev/>|
|DefectDojo|DefectDojo DB setup (one-shot)| 172.20.4.40| <https://defectdojo.com/>|
|DefectDojo|DefectDojo initializer (one-shot)| 172.20.4.41| <https://defectdojo.com/>|
|DefectDojo|DefectDojo uWSGI| 172.20.4.42| <https://defectdojo.com/>|
|DefectDojo|DefectDojo Celery beat| 172.20.4.43| <https://defectdojo.com/>|
|DefectDojo|DefectDojo Celery worker| 172.20.4.44| <https://defectdojo.com/>|
|DefectDojo|DefectDojo nginx| 172.20.4.45| <https://defectdojo.com/>|
|DefectDojo|DefectDojo Valkey| 172.20.4.46| <https://valkey.io/>|

## Containerization (172.20.5.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|DockerRegistry|Docker Registry| 172.20.5.10| <https://distribution.github.io/distribution/>|
|DockerRegistry|Docker Registry UI| 172.20.5.11| <https://github.com/Joxit/docker-registry-ui>|
|Dozzle|Dozzle| 172.20.5.20| <https://dozzle.dev/>|
|Zot|zot registry| 172.20.5.30| <https://zotregistry.dev/>|
|Harbor|Harbor DB setup (one-shot)| 172.20.5.40| <https://goharbor.io/>|
|Harbor|Harbor key/config setup (one-shot)| 172.20.5.41| <https://goharbor.io/>|
|Harbor|Harbor registry| 172.20.5.42| <https://goharbor.io/>|
|Harbor|Harbor registryctl| 172.20.5.43| <https://goharbor.io/>|
|Harbor|Harbor core| 172.20.5.44| <https://goharbor.io/>|
|Harbor|Harbor portal| 172.20.5.45| <https://goharbor.io/>|
|Harbor|Harbor jobservice| 172.20.5.46| <https://goharbor.io/>|
|Harbor|Harbor Redis (Valkey)| 172.20.5.47| <https://goharbor.io/>|
|Harbor|Harbor proxy (nginx)| 172.20.5.48| <https://goharbor.io/>|
|Harbor|Harbor Trivy adapter| 172.20.5.49| <https://goharbor.io/>|

## Databases (172.20.6.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|ApacheCassandra|Apache Cassandra| 172.20.6.10| <https://cassandra.apache.org/>|
|ClickHouse|ClickHouse| 172.20.6.20| <https://clickhouse.com/>|
|CockroachDB|CockroachDB| 172.20.6.30| <https://www.cockroachlabs.com/>|
|KurrentDB|KurrentDB (formerly EventStoreDB)| 172.20.6.40| <https://www.kurrent.io/>|
|InfluxDb|InfluxDB| 172.20.6.50| <https://www.influxdata.com/>|
|MariaDb|MariaDB| 172.20.6.60| <https://mariadb.org/>|
|MariaDb|Adminer| 172.20.6.61| <https://www.adminer.org/>|
|Milvus|Milvus etcd| 172.20.6.70| <https://etcd.io/>|
|Milvus|Milvus MinIO| 172.20.6.71| <https://github.com/minio/minio>|
|Milvus|Milvus| 172.20.6.72| <https://milvus.io/>|
|MongoDB|MongoDB| 172.20.6.80| <https://www.mongodb.com/>|
|MongoDB|Mongo Express| 172.20.6.81| <https://github.com/mongo-express/mongo-express>|
|MSSQL|MSSQL| 172.20.6.90| <https://www.microsoft.com/en-us/sql-server/>|
|MySQL|MySQL| 172.20.6.100| <https://www.mysql.com/>|
|MySQL|phpMyAdmin| 172.20.6.101| <https://www.phpmyadmin.net/>|
|Neo4J|Neo4j| 172.20.6.110| <https://neo4j.com/>|
|Oracle|Oracle| 172.20.6.120| <https://www.oracle.com/database/>|
|PostgreSQL|PostgreSQL (with pgvector)| 172.20.6.130| <https://www.postgresql.org/>|
|PostgreSQL|pgAdmin4| 172.20.6.131| <https://www.pgadmin.org/>|
| *(.140-.149 free: Prometheus moved to Observability)*| | |
|Redis|Redis| 172.20.6.150| <https://redis.io/>|
|RavenDB|RavenDB| 172.20.6.160| <https://ravendb.net/>|
|CouchDB|CouchDB| 172.20.6.170| <https://couchdb.apache.org/>|
|CouchDB|CouchDB setup (one-shot)| 172.20.6.171| <https://couchdb.apache.org/>|
|Couchbase|Couchbase Server CE| 172.20.6.180| <https://www.couchbase.com/>|
|Couchbase|Couchbase setup (one-shot)| 172.20.6.181| <https://www.couchbase.com/>|
|Garnet|Garnet| 172.20.6.190| <https://microsoft.github.io/garnet/>|
|Memcached|Memcached| 172.20.6.200| <https://memcached.org/>|
|Qdrant|Qdrant| 172.20.6.210| <https://qdrant.tech/>|
|ScyllaDB|ScyllaDB| 172.20.6.220| <https://www.scylladb.com/>|
|CloudBeaver|CloudBeaver| 172.20.6.230| <https://github.com/dbeaver/cloudbeaver>|
|TimescaleDB|TimescaleDB| 172.20.6.240| <https://github.com/timescale/timescaledb>|
|Valkey|Valkey| 172.20.6.250| <https://valkey.io/>|

## Documentation (172.20.7.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Backstage|Backstage| 172.20.7.10| <https://backstage.io/>|
|Mediawiki|MediaWiki| 172.20.7.20| <https://www.mediawiki.org/>|
|WikiJs|Wiki.js DB setup (one-shot)| 172.20.7.30| <https://js.wiki/>|
|WikiJs|Wiki.js| 172.20.7.31| <https://js.wiki/>|
|BookStack|BookStack DB setup (one-shot)| 172.20.7.40| <https://www.bookstackapp.com/>|
|BookStack|BookStack| 172.20.7.41| <https://www.bookstackapp.com/>|
|Outline|Outline DB setup (one-shot)| 172.20.7.50| <https://www.getoutline.com/>|
|Outline|Outline Redis| 172.20.7.51| <https://redis.io/>|
|Outline|Dex (OIDC login for Outline)| 172.20.7.52| <https://dexidp.io/>|
|Outline|Outline| 172.20.7.53| <https://www.getoutline.com/>|
|Structurizr|Structurizr (local)| 172.20.7.60| <https://structurizr.com/>|
|Kroki|Kroki| 172.20.7.70| <https://kroki.io/>|
|Kroki|Kroki Mermaid| 172.20.7.71| <https://kroki.io/>|
|Kroki|Kroki BPMN| 172.20.7.72| <https://kroki.io/>|
|Kroki|Kroki Excalidraw| 172.20.7.73| <https://kroki.io/>|
|DrawIo|draw.io| 172.20.7.80| <https://www.drawio.com/>|
|ApiDocs|Swagger UI| 172.20.7.90| <https://swagger.io/tools/swagger-ui/>|
|ApiDocs|Redoc| 172.20.7.91| <https://redocly.com/redoc>|

## Email (172.20.8.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Mailpit|Mailpit| 172.20.8.10| <https://mailpit.axllent.org/>|
|Smtp4dev|smtp4dev| 172.20.8.20| <https://github.com/rnwood/smtp4dev>|

## IaC (172.20.9.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Terraform|Terraform| 172.20.9.10| <https://developer.hashicorp.com/terraform>|
|OpenTofu|OpenTofu| 172.20.9.20| <https://opentofu.org/>|
|Atlantis|Atlantis setup (one-shot)| 172.20.9.30| <https://www.runatlantis.io/>|
|Atlantis|Atlantis| 172.20.9.31| <https://www.runatlantis.io/>|
|Semaphore|Semaphore DB setup (one-shot)| 172.20.9.40| <https://semaphoreui.com/>|
|Semaphore|Semaphore UI| 172.20.9.41| <https://semaphoreui.com/>|

## Messaging (172.20.10.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Kafka|Kafka| 172.20.10.10| <https://kafka.apache.org/>|
|Kafka|Kafka UI| 172.20.10.11| <https://github.com/kafbat/kafka-ui>|
|RabbitMQ|RabbitMQ| 172.20.10.20| <https://www.rabbitmq.com/>|
|NATS|NATS (JetStream)| 172.20.10.30| <https://nats.io/>|
|Mosquitto|Mosquitto (MQTT)| 172.20.10.40| <https://mosquitto.org/>|
|Artemis|Apache Artemis| 172.20.10.50| <https://activemq.apache.org/components/artemis/>|
|Redpanda|Redpanda| 172.20.10.60| <https://www.redpanda.com/>|
|Redpanda|Redpanda Console| 172.20.10.61| <https://github.com/redpanda-data/console>|
|Pulsar|Apache Pulsar (standalone)| 172.20.10.70| <https://pulsar.apache.org/>|
|Debezium|Debezium (Kafka Connect)| 172.20.10.80| <https://debezium.io/>|
|Apicurio|Apicurio DB setup (one-shot)| 172.20.10.90| <https://www.apicur.io/registry/>|
|Apicurio|Apicurio Registry| 172.20.10.91| <https://www.apicur.io/registry/>|
|Apicurio|Apicurio Registry UI| 172.20.10.92| <https://www.apicur.io/registry/>|

## Observability (172.20.11.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|AspireDashboard|Aspire Dashboard| 172.20.11.10| <https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/dashboard/standalone>|
|OpenTelemetry|OpenTelemetry Collector| 172.20.11.20| <https://opentelemetry.io/docs/collector/>|
|OpenTelemetry|Tempo| 172.20.11.21| <https://grafana.com/oss/tempo/>|
|OpenTelemetry|Loki| 172.20.11.22| <https://grafana.com/oss/loki/>|
|Prometheus|Prometheus| 172.20.11.30| <https://prometheus.io/>|
|Prometheus|Prometheus Node Exporter| 172.20.11.31| <https://github.com/prometheus/node_exporter>|
|Prometheus|Prometheus Alertmanager| 172.20.11.32| <https://prometheus.io/docs/alerting/latest/alertmanager/>|
|Jaeger|Jaeger v2| 172.20.11.40| <https://www.jaegertracing.io/>|
|Pyroscope|Grafana Pyroscope| 172.20.11.50| <https://grafana.com/oss/pyroscope/>|
|UptimeKuma|Uptime Kuma| 172.20.11.60| <https://uptime.kuma.pet/>|
|cAdvisor|cAdvisor| 172.20.11.70| <https://github.com/google/cadvisor>|
|OtelLgtm|grafana/otel-lgtm| 172.20.11.80| <https://github.com/grafana/docker-otel-lgtm>|
|SigNoz|SigNoz DB setup (one-shot)| 172.20.11.90| <https://signoz.io/>|
|SigNoz|SigNoz ClickHouse Keeper| 172.20.11.91| <https://clickhouse.com/>|
|SigNoz|SigNoz ClickHouse UDF setup (one-shot)| 172.20.11.92| <https://signoz.io/>|
|SigNoz|SigNoz ClickHouse| 172.20.11.93| <https://clickhouse.com/>|
|SigNoz|SigNoz schema migrator (one-shot)| 172.20.11.94| <https://signoz.io/>|
|SigNoz|SigNoz| 172.20.11.95| <https://signoz.io/>|
|SigNoz|SigNoz collector| 172.20.11.96| <https://signoz.io/>|

## Orchestration (172.20.12.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Kubernetes| *(no compose stack - block .10-.19 reserved)*| |
|Portainer|Portainer| 172.20.12.20| <https://www.portainer.io/>|
|Rancher|Rancher| 172.20.12.30| <https://www.rancher.com/>|
|K3s|K3s (Kubernetes) + Argo CD| 172.20.12.40| <https://k3s.io/>|
|K3s|K3s setup (one-shot: kubeconfig, DNS, Argo CD)| 172.20.12.41| <https://k3s.io/>|
|Headlamp|Headlamp| 172.20.12.50| <https://headlamp.dev/>|
|Nomad|HashiCorp Nomad| 172.20.12.60| <https://www.nomadproject.io/>|

## Packages (172.20.13.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Proget|ProGet| 172.20.13.10| <https://inedo.com/proget>|
|Nexus|Sonatype Nexus CE| 172.20.13.20| <https://www.sonatype.com/products/sonatype-nexus-repository>|
|Nexus|Nexus setup (one-shot)| 172.20.13.21| <https://www.sonatype.com/products/sonatype-nexus-repository>|
|BaGetter|BaGetter| 172.20.13.30| <https://www.bagetter.com/>|
|Verdaccio|Verdaccio| 172.20.13.40| <https://verdaccio.org/>|

## RP-LB (172.20.14.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|HAProxy|HAProxy| 172.20.14.10| <https://www.haproxy.org/>|
|NginxProxyManager|Nginx Proxy Manager| 172.20.14.20| <https://nginxproxymanager.com/>|
|Traefik|Traefik| 172.20.14.30| <https://traefik.io/traefik/>|
|Caddy|Caddy| 172.20.14.40| <https://caddyserver.com/>|
|Yarp|YARP (.NET reverse proxy)| 172.20.14.50| <https://github.com/dotnet/yarp>|
|Envoy|Envoy| 172.20.14.60| <https://www.envoyproxy.io/>|
|Kong|Kong Gateway (OSS, DB-less)| 172.20.14.70| <https://konghq.com/products/kong-gateway>|

## Scheduling (172.20.15.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Hangfire|Hangfire| 172.20.15.10| <https://www.hangfire.io/>|
|Temporal|Temporal database setup (one-shot)| 172.20.15.20| <https://temporal.io/>|
|Temporal|Temporal schema setup (one-shot)| 172.20.15.21| <https://temporal.io/>|
|Temporal|Temporal server| 172.20.15.22| <https://temporal.io/>|
|Temporal|Temporal namespace setup (one-shot)| 172.20.15.23| <https://temporal.io/>|
|Temporal|Temporal UI| 172.20.15.24| <https://temporal.io/>|
|Airflow|Airflow database setup (one-shot)| 172.20.15.30| <https://airflow.apache.org/>|
|Airflow|Airflow init (one-shot)| 172.20.15.31| <https://airflow.apache.org/>|
|Airflow|Airflow API server| 172.20.15.32| <https://airflow.apache.org/>|
|Airflow|Airflow scheduler| 172.20.15.33| <https://airflow.apache.org/>|
|Airflow|Airflow DAG processor| 172.20.15.34| <https://airflow.apache.org/>|
|Airflow|Airflow triggerer| 172.20.15.35| <https://airflow.apache.org/>|
|Rundeck|Rundeck database setup (one-shot)| 172.20.15.40| <https://www.rundeck.com/>|
|Rundeck|Rundeck| 172.20.15.41| <https://www.rundeck.com/>|
|N8n|n8n database setup (one-shot)| 172.20.15.50| <https://n8n.io/>|
|N8n|n8n| 172.20.15.51| <https://n8n.io/>|
|N8n|n8n owner setup (one-shot)| 172.20.15.52| <https://n8n.io/>|
|N8n|n8n task runners| 172.20.15.53| <https://n8n.io/>|
|Camunda|Camunda 8 Orchestration Cluster| 172.20.15.60| <https://camunda.com/>|
|Camunda|Camunda 8 Connectors| 172.20.15.61| <https://camunda.com/>|
|NodeRed|Node-RED| 172.20.15.70| <https://nodered.org/>|

## Search (172.20.16.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|ElasticSearch|Elasticsearch setup (one-shot)| 172.20.16.10| <https://www.elastic.co/elasticsearch>|
|ElasticSearch|Elasticsearch (es01)| 172.20.16.11| <https://www.elastic.co/elasticsearch>|
|ElasticSearch|Kibana| 172.20.16.12| <https://www.elastic.co/kibana>|
|ElasticSearch|Metricbeat| 172.20.16.13| <https://www.elastic.co/beats/metricbeat>|
|ElasticSearch|Filebeat| 172.20.16.14| <https://www.elastic.co/beats/filebeat>|
|ElasticSearch|Logstash| 172.20.16.15| <https://www.elastic.co/logstash>|
|OpenSearch|OpenSearch node 1| 172.20.16.20| <https://opensearch.org/>|
|OpenSearch|OpenSearch node 2| 172.20.16.21| <https://opensearch.org/>|
|OpenSearch|OpenSearch Dashboards| 172.20.16.22| <https://opensearch.org/>|
|Meilisearch|Meilisearch| 172.20.16.30| <https://www.meilisearch.com/>|
|Typesense|Typesense| 172.20.16.40| <https://typesense.org/>|
|Solr|Apache Solr| 172.20.16.50| <https://solr.apache.org/>|

## Security (172.20.17.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Vault|Vault| 172.20.17.10| <https://www.vaultproject.io/>|
|OpenBao|OpenBao| 172.20.17.20| <https://openbao.org/>|
|StepCa|step-ca| 172.20.17.30| <https://smallstep.com/docs/step-ca/>|
|Zap|ZAP (headless proxy + API)| 172.20.17.40| <https://www.zaproxy.org/>|
|Zap|ZAP desktop UI (profile "ui")| 172.20.17.41| <https://www.zaproxy.org/>|
|Infisical|Infisical database setup (one-shot)| 172.20.17.50| <https://infisical.com/>|
|Infisical|Infisical| 172.20.17.51| <https://infisical.com/>|
|Infisical|Infisical admin setup (one-shot)| 172.20.17.52| <https://infisical.com/>|

## SIEM (172.20.18.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Wazuh|Wazuh certs generator (one-shot)| 172.20.18.10| <https://wazuh.com/>|
|Wazuh|Wazuh Manager| 172.20.18.11| <https://wazuh.com/>|
|Wazuh|Wazuh Indexer| 172.20.18.12| <https://wazuh.com/>|
|Wazuh|Wazuh Dashboard| 172.20.18.13| <https://wazuh.com/>|
|Graylog|Graylog MongoDB| 172.20.18.20| <https://www.mongodb.com/>|
|Graylog|Graylog Data Node| 172.20.18.21| <https://graylog.org/>|
|Graylog|Graylog| 172.20.18.22| <https://graylog.org/>|

## SourceControl (172.20.19.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Gitea|Gitea| 172.20.19.10| <https://about.gitea.com/>|
|Gitea|Gitea Actions runner| 172.20.19.11| <https://about.gitea.com/>|
|Forgejo|Forgejo| 172.20.19.20| <https://forgejo.org/>|
|Forgejo|Forgejo admin + runner token setup (one-shot)| 172.20.19.21| <https://forgejo.org/>|
|Forgejo|Forgejo Actions runner| 172.20.19.22| <https://forgejo.org/>|
|GitLab|GitLab CE| 172.20.19.30| <https://about.gitlab.com/>|
|OneDev|OneDev| 172.20.19.40| <https://onedev.io/>|

## Visualization (172.20.20.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Grafana|Grafana| 172.20.20.10| <https://grafana.com/oss/grafana/>|
|Metabase|Metabase database setup (one-shot)| 172.20.20.20| <https://www.metabase.com/>|
|Metabase|Metabase| 172.20.20.21| <https://www.metabase.com/>|
|Metabase|Metabase admin setup (one-shot)| 172.20.20.22| <https://www.metabase.com/>|
|Superset|Superset database setup (one-shot)| 172.20.20.30| <https://superset.apache.org/>|
|Superset|Superset init (one-shot)| 172.20.20.31| <https://superset.apache.org/>|
|Superset|Superset| 172.20.20.32| <https://superset.apache.org/>|
|Redash|Redash database setup (one-shot)| 172.20.20.40| <https://redash.io/>|
|Redash|Redash init (one-shot)| 172.20.20.41| <https://redash.io/>|
|Redash|Redash server| 172.20.20.42| <https://redash.io/>|
|Redash|Redash scheduler| 172.20.20.43| <https://redash.io/>|
|Redash|Redash worker| 172.20.20.44| <https://redash.io/>|

## WebServers (172.20.21.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Apache|Apache| 172.20.21.10| <https://httpd.apache.org/>|
|Nginx|Nginx| 172.20.21.20| <https://nginx.org/>|
|Nginx|Nginx UI| 172.20.21.21| <https://nginxui.com/>|

## CI-CD (172.20.22.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Jenkins|Jenkins| 172.20.22.10| <https://www.jenkins.io/>|
|TeamCity|TeamCity server| 172.20.22.20| <https://www.jetbrains.com/teamcity/>|
|TeamCity|TeamCity build agent| 172.20.22.21| <https://www.jetbrains.com/teamcity/>|
|Woodpecker|Woodpecker Gitea OAuth2 setup (one-shot)| 172.20.22.30| <https://woodpecker-ci.org/>|
|Woodpecker|Woodpecker server| 172.20.22.31| <https://woodpecker-ci.org/>|
|Woodpecker|Woodpecker agent| 172.20.22.32| <https://woodpecker-ci.org/>|

## Testing (172.20.23.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|WireMock|WireMock| 172.20.23.10| <https://wiremock.org/>|
|Microcks|Microcks (uber)| 172.20.23.20| <https://microcks.io/>|
|Microcks|Microcks artifact import (one-shot)| 172.20.23.21| <https://microcks.io/>|
|Mockoon|Mockoon CLI| 172.20.23.30| <https://mockoon.com/>|
|K6|k6 (one-shot test run)| 172.20.23.40| <https://k6.io/>|
|Toxiproxy|Toxiproxy| 172.20.23.50| <https://github.com/Shopify/toxiproxy>|
|SeleniumGrid|Selenium hub| 172.20.23.60| <https://www.selenium.dev/documentation/grid/>|
|SeleniumGrid|Selenium Chrome node| 172.20.23.61| <https://www.selenium.dev/documentation/grid/>|
|SeleniumGrid|Selenium Firefox node| 172.20.23.62| <https://www.selenium.dev/documentation/grid/>|
|SeleniumGrid|Selenium Edge node| 172.20.23.63| <https://www.selenium.dev/documentation/grid/>|
|PactBroker|Pact Broker database setup (one-shot)| 172.20.23.70| <https://docs.pact.io/pact_broker>|
|PactBroker|Pact Broker| 172.20.23.71| <https://docs.pact.io/pact_broker>|
|Hoppscotch|Hoppscotch database setup (one-shot)| 172.20.23.80| <https://hoppscotch.io/>|
|Hoppscotch|Hoppscotch migrations (one-shot)| 172.20.23.81| <https://hoppscotch.io/>|
|Hoppscotch|Hoppscotch| 172.20.23.82| <https://hoppscotch.io/>|
|Hoppscotch|Hoppscotch onboarding (one-shot)| 172.20.23.83| <https://hoppscotch.io/>|

## FeatureFlags (172.20.24.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Unleash|Unleash database setup (one-shot)| 172.20.24.10| <https://www.getunleash.io/>|
|Unleash|Unleash| 172.20.24.11| <https://www.getunleash.io/>|
|Flagsmith|Flagsmith database setup (one-shot)| 172.20.24.20| <https://www.flagsmith.com/>|
|Flagsmith|Flagsmith| 172.20.24.21| <https://www.flagsmith.com/>|
|Flagsmith|Flagsmith admin + environments setup (one-shot)| 172.20.24.22| <https://www.flagsmith.com/>|
|GrowthBook|GrowthBook MongoDB 8.0| 172.20.24.30| <https://www.mongodb.com/>|
|GrowthBook|GrowthBook| 172.20.24.31| <https://www.growthbook.io/>|
|GrowthBook|GrowthBook first-time setup (one-shot)| 172.20.24.32| <https://www.growthbook.io/>|
|Flagd|flagd| 172.20.24.40| <https://flagd.dev/>|
|Consul|Consul server| 172.20.24.50| <https://www.consul.io/>|
|Consul|Consul KV seed (one-shot)| 172.20.24.51| <https://www.consul.io/>|

## ObjectStorage (172.20.25.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|RustFS|RustFS| 172.20.25.10| <https://rustfs.com/>|
|RustFS|RustFS bucket setup (one-shot)| 172.20.25.11| <https://rustfs.com/>|
|SeaweedFS|SeaweedFS (weed mini)| 172.20.25.20| <https://github.com/seaweedfs/seaweedfs>|
|Garage|Garage| 172.20.25.30| <https://garagehq.deuxfleurs.fr/>|
|Garage|Garage layout/key/bucket setup (one-shot)| 172.20.25.31| <https://garagehq.deuxfleurs.fr/>|
|Garage|Garage web UI| 172.20.25.32| <https://github.com/khairul169/garage-webui>|

## ServiceMesh (172.20.26.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Dapr|Dapr placement| 172.20.26.10| <https://dapr.io/>|
|Dapr|Dapr scheduler| 172.20.26.11| <https://dapr.io/>|
|Dapr|Dapr dashboard| 172.20.26.12| <https://github.com/dapr/dashboard>|
|Dapr|Dapr sidecar (daprd for an app on the host)| 172.20.26.20| <https://dapr.io/>|

## AI (172.20.27.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Ollama|Ollama| 172.20.27.10| <https://ollama.com/>|
|Ollama|Ollama model pull (one-shot)| 172.20.27.11| <https://ollama.com/>|
|OpenWebUI|Open WebUI| 172.20.27.20| <https://openwebui.com/>|
|LiteLLM|LiteLLM database setup (one-shot)| 172.20.27.30| <https://www.litellm.ai/>|
|LiteLLM|LiteLLM proxy| 172.20.27.31| <https://www.litellm.ai/>|
|Langfuse|Langfuse database setup (one-shot)| 172.20.27.40| <https://langfuse.com/>|
|Langfuse|Langfuse S3 bucket setup (one-shot)| 172.20.27.41| <https://langfuse.com/>|
|Langfuse|Langfuse ClickHouse| 172.20.27.42| <https://clickhouse.com/>|
|Langfuse|Langfuse web| 172.20.27.43| <https://langfuse.com/>|
|Langfuse|Langfuse worker| 172.20.27.44| <https://langfuse.com/>|

## DataIntegration (172.20.28.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|NiFi|Apache NiFi| 172.20.28.10| <https://nifi.apache.org/>|
|NiFi|NiFi conf setup (one-shot)| 172.20.28.11| <https://nifi.apache.org/>|
|Airbyte|Airbyte database setup (one-shot)| 172.20.28.20| <https://airbyte.com/>|
|Airbyte|Airbyte Helm install into K3s (one-shot)| 172.20.28.21| <https://airbyte.com/>|
|Airbyte|Airbyte proxy (localhost:8154 -> K3s NodePort 30081)| 172.20.28.22| <https://airbyte.com/>|

## Collaboration (172.20.29.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Mattermost|Mattermost database setup (one-shot)| 172.20.29.10| <https://mattermost.com/>|
|Mattermost|Mattermost| 172.20.29.11| <https://mattermost.com/>|
|Mattermost|Mattermost admin/team setup (one-shot)| 172.20.29.12| <https://mattermost.com/>|
|RocketChat|Rocket.Chat MongoDB (replica set)| 172.20.29.20| <https://www.mongodb.com/>|
|RocketChat|Rocket.Chat replica set init (one-shot)| 172.20.29.21| <https://www.rocket.chat/>|
|RocketChat|Rocket.Chat| 172.20.29.22| <https://www.rocket.chat/>|
|Plane|Plane database setup (one-shot)| 172.20.29.30| <https://plane.so/>|
|Plane|Plane S3 store (RustFS)| 172.20.29.31| <https://rustfs.com/>|
|Plane|Plane migrator (one-shot)| 172.20.29.32| <https://plane.so/>|
|Plane|Plane API| 172.20.29.33| <https://plane.so/>|
|Plane|Plane worker| 172.20.29.34| <https://plane.so/>|
|Plane|Plane beat worker| 172.20.29.35| <https://plane.so/>|
|Plane|Plane web| 172.20.29.36| <https://plane.so/>|
|Plane|Plane space| 172.20.29.37| <https://plane.so/>|
|Plane|Plane admin (god mode)| 172.20.29.38| <https://plane.so/>|
|Plane|Plane live| 172.20.29.39| <https://plane.so/>|
|Plane|Plane proxy| 172.20.29.40| <https://plane.so/>|
|Plane|Plane admin setup (one-shot)| 172.20.29.41| <https://plane.so/>|
|Plane|Plane RabbitMQ broker| 172.20.29.42| <https://www.rabbitmq.com/>|

## DevTools (172.20.30.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Homepage|Homepage| 172.20.30.10| <https://gethomepage.dev/>|
|Homarr|Homarr| 172.20.30.20| <https://homarr.dev/>|
|Homarr|Homarr admin/onboarding setup (one-shot)| 172.20.30.21| <https://homarr.dev/>|
|ITTools|IT-Tools| 172.20.30.30| <https://it-tools.tech/>|
|CyberChef|CyberChef| 172.20.30.40| <https://gchq.github.io/CyberChef/>|
|CodeServer|code-server (.NET SDK)| 172.20.30.50| <https://coder.com/docs/code-server>|
