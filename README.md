Check out <a href="https://scott.vercuski.com" target="_blank" rel="noopener noreferrer">https://scott.vercuski.com</a> for more projects and solution/software architecture knowledge.

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
|Apache Spark|Apache Spark (master)| 172.20.1.10| <a href="https://spark.apache.org/" target="_blank" rel="noopener noreferrer">https://spark.apache.org/</a>|
|Apache Spark|Apache Spark Worker| 172.20.1.11| <a href="https://spark.apache.org/" target="_blank" rel="noopener noreferrer">https://spark.apache.org/</a>|
|Seq|Seq| 172.20.1.20| <a href="https://datalust.co/seq" target="_blank" rel="noopener noreferrer">https://datalust.co/seq</a>|
|ApacheFlink|Flink JobManager| 172.20.1.30| <a href="https://flink.apache.org/" target="_blank" rel="noopener noreferrer">https://flink.apache.org/</a>|
|ApacheFlink|Flink TaskManager| 172.20.1.31| <a href="https://flink.apache.org/" target="_blank" rel="noopener noreferrer">https://flink.apache.org/</a>|
|Trino|Trino| 172.20.1.40| <a href="https://trino.io/" target="_blank" rel="noopener noreferrer">https://trino.io/</a>|
|JupyterLab|JupyterLab| 172.20.1.50| <a href="https://jupyter.org/" target="_blank" rel="noopener noreferrer">https://jupyter.org/</a>|

## Authentication (172.20.2.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Keycloak|Keycloak| 172.20.2.10| <a href="https://www.keycloak.org/" target="_blank" rel="noopener noreferrer">https://www.keycloak.org/</a>|
|Supertokens|SuperTokens| 172.20.2.20| <a href="https://supertokens.com/" target="_blank" rel="noopener noreferrer">https://supertokens.com/</a>|
|Authentik|authentik DB setup (one-shot)| 172.20.2.30| <a href="https://goauthentik.io/" target="_blank" rel="noopener noreferrer">https://goauthentik.io/</a>|
|Authentik|authentik server| 172.20.2.31| <a href="https://goauthentik.io/" target="_blank" rel="noopener noreferrer">https://goauthentik.io/</a>|
|Authentik|authentik worker| 172.20.2.32| <a href="https://goauthentik.io/" target="_blank" rel="noopener noreferrer">https://goauthentik.io/</a>|
|Zitadel|ZITADEL DB setup (one-shot)| 172.20.2.40| <a href="https://zitadel.com/" target="_blank" rel="noopener noreferrer">https://zitadel.com/</a>|
|Zitadel|ZITADEL + Login UI (shared network)| 172.20.2.41| <a href="https://zitadel.com/" target="_blank" rel="noopener noreferrer">https://zitadel.com/</a>|
|Authelia|Authelia cert/key setup (one-shot)| 172.20.2.50| <a href="https://www.authelia.com/" target="_blank" rel="noopener noreferrer">https://www.authelia.com/</a>|
|Authelia|Authelia| 172.20.2.51| <a href="https://www.authelia.com/" target="_blank" rel="noopener noreferrer">https://www.authelia.com/</a>|
|Ory|Ory DB setup (one-shot)| 172.20.2.60| <a href="https://www.ory.sh/" target="_blank" rel="noopener noreferrer">https://www.ory.sh/</a>|
|Ory|Kratos migrations (one-shot)| 172.20.2.61| <a href="https://www.ory.sh/kratos/" target="_blank" rel="noopener noreferrer">https://www.ory.sh/kratos/</a>|
|Ory|Kratos| 172.20.2.62| <a href="https://www.ory.sh/kratos/" target="_blank" rel="noopener noreferrer">https://www.ory.sh/kratos/</a>|
|Ory|Hydra migrations (one-shot)| 172.20.2.63| <a href="https://www.ory.sh/hydra/" target="_blank" rel="noopener noreferrer">https://www.ory.sh/hydra/</a>|
|Ory|Hydra| 172.20.2.64| <a href="https://www.ory.sh/hydra/" target="_blank" rel="noopener noreferrer">https://www.ory.sh/hydra/</a>|
|Ory|Kratos self-service UI| 172.20.2.65| <a href="https://github.com/ory/kratos-selfservice-ui-node" target="_blank" rel="noopener noreferrer">https://github.com/ory/kratos-selfservice-ui-node</a>|

## CloudEmulators (172.20.3.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|AzureCosmosDb|Azure Cosmos DB emulator| 172.20.3.10| <a href="https://learn.microsoft.com/en-us/azure/cosmos-db/emulator" target="_blank" rel="noopener noreferrer">https://learn.microsoft.com/en-us/azure/cosmos-db/emulator</a>|
|AzureServiceBus|Azure Service Bus emulator| 172.20.3.20| <a href="https://learn.microsoft.com/en-us/azure/service-bus-messaging/overview-emulator" target="_blank" rel="noopener noreferrer">https://learn.microsoft.com/en-us/azure/service-bus-messaging/overview-emulator</a>|
|Azurite|Azurite| 172.20.3.30| <a href="https://github.com/Azure/Azurite" target="_blank" rel="noopener noreferrer">https://github.com/Azure/Azurite</a>|
|AzureEventHubs|Azure Event Hubs emulator| 172.20.3.40| <a href="https://learn.microsoft.com/en-us/azure/event-hubs/overview-emulator" target="_blank" rel="noopener noreferrer">https://learn.microsoft.com/en-us/azure/event-hubs/overview-emulator</a>|
|Floci|Floci (AWS emulator)| 172.20.3.50| <a href="https://hub.docker.com/r/floci/floci" target="_blank" rel="noopener noreferrer">https://hub.docker.com/r/floci/floci</a>|
|LocalStack|LocalStack (AWS emulator, auth token)| 172.20.3.60| <a href="https://www.localstack.cloud/" target="_blank" rel="noopener noreferrer">https://www.localstack.cloud/</a>|
|GcpPubSub|Google Cloud Pub/Sub emulator| 172.20.3.70| <a href="https://cloud.google.com/pubsub/docs/emulator" target="_blank" rel="noopener noreferrer">https://cloud.google.com/pubsub/docs/emulator</a>|
|GcpFirestore|Google Cloud Firestore emulator| 172.20.3.80| <a href="https://cloud.google.com/firestore/docs/emulator" target="_blank" rel="noopener noreferrer">https://cloud.google.com/firestore/docs/emulator</a>|
|GcpSpanner|Google Cloud Spanner emulator| 172.20.3.90| <a href="https://cloud.google.com/spanner/docs/emulator" target="_blank" rel="noopener noreferrer">https://cloud.google.com/spanner/docs/emulator</a>|
|LowkeyVault|Lowkey Vault (Azure Key Vault emulator)| 172.20.3.100| <a href="https://github.com/nagyesta/lowkey-vault" target="_blank" rel="noopener noreferrer">https://github.com/nagyesta/lowkey-vault</a>|

## CodeAnalysis (172.20.4.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Sonarqube|SonarQube| 172.20.4.10| <a href="https://www.sonarsource.com/products/sonarqube/" target="_blank" rel="noopener noreferrer">https://www.sonarsource.com/products/sonarqube/</a>|
|DependencyTrack|Dependency-Track DB setup (one-shot)| 172.20.4.20| <a href="https://dependencytrack.org/" target="_blank" rel="noopener noreferrer">https://dependencytrack.org/</a>|
|DependencyTrack|Dependency-Track API server| 172.20.4.21| <a href="https://dependencytrack.org/" target="_blank" rel="noopener noreferrer">https://dependencytrack.org/</a>|
|DependencyTrack|Dependency-Track frontend| 172.20.4.22| <a href="https://dependencytrack.org/" target="_blank" rel="noopener noreferrer">https://dependencytrack.org/</a>|
|Trivy|Trivy server| 172.20.4.30| <a href="https://trivy.dev/" target="_blank" rel="noopener noreferrer">https://trivy.dev/</a>|
|DefectDojo|DefectDojo DB setup (one-shot)| 172.20.4.40| <a href="https://defectdojo.com/" target="_blank" rel="noopener noreferrer">https://defectdojo.com/</a>|
|DefectDojo|DefectDojo initializer (one-shot)| 172.20.4.41| <a href="https://defectdojo.com/" target="_blank" rel="noopener noreferrer">https://defectdojo.com/</a>|
|DefectDojo|DefectDojo uWSGI| 172.20.4.42| <a href="https://defectdojo.com/" target="_blank" rel="noopener noreferrer">https://defectdojo.com/</a>|
|DefectDojo|DefectDojo Celery beat| 172.20.4.43| <a href="https://defectdojo.com/" target="_blank" rel="noopener noreferrer">https://defectdojo.com/</a>|
|DefectDojo|DefectDojo Celery worker| 172.20.4.44| <a href="https://defectdojo.com/" target="_blank" rel="noopener noreferrer">https://defectdojo.com/</a>|
|DefectDojo|DefectDojo nginx| 172.20.4.45| <a href="https://defectdojo.com/" target="_blank" rel="noopener noreferrer">https://defectdojo.com/</a>|
|DefectDojo|DefectDojo Valkey| 172.20.4.46| <a href="https://valkey.io/" target="_blank" rel="noopener noreferrer">https://valkey.io/</a>|

## Containerization (172.20.5.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|DockerRegistry|Docker Registry| 172.20.5.10| <a href="https://distribution.github.io/distribution/" target="_blank" rel="noopener noreferrer">https://distribution.github.io/distribution/</a>|
|DockerRegistry|Docker Registry UI| 172.20.5.11| <a href="https://github.com/Joxit/docker-registry-ui" target="_blank" rel="noopener noreferrer">https://github.com/Joxit/docker-registry-ui</a>|
|Dozzle|Dozzle| 172.20.5.20| <a href="https://dozzle.dev/" target="_blank" rel="noopener noreferrer">https://dozzle.dev/</a>|
|Zot|zot registry| 172.20.5.30| <a href="https://zotregistry.dev/" target="_blank" rel="noopener noreferrer">https://zotregistry.dev/</a>|
|Harbor|Harbor DB setup (one-shot)| 172.20.5.40| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor key/config setup (one-shot)| 172.20.5.41| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor registry| 172.20.5.42| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor registryctl| 172.20.5.43| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor core| 172.20.5.44| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor portal| 172.20.5.45| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor jobservice| 172.20.5.46| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor Redis (Valkey)| 172.20.5.47| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor proxy (nginx)| 172.20.5.48| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|
|Harbor|Harbor Trivy adapter| 172.20.5.49| <a href="https://goharbor.io/" target="_blank" rel="noopener noreferrer">https://goharbor.io/</a>|

## Databases (172.20.6.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|ApacheCassandra|Apache Cassandra| 172.20.6.10| <a href="https://cassandra.apache.org/" target="_blank" rel="noopener noreferrer">https://cassandra.apache.org/</a>|
|ClickHouse|ClickHouse| 172.20.6.20| <a href="https://clickhouse.com/" target="_blank" rel="noopener noreferrer">https://clickhouse.com/</a>|
|CockroachDB|CockroachDB| 172.20.6.30| <a href="https://www.cockroachlabs.com/" target="_blank" rel="noopener noreferrer">https://www.cockroachlabs.com/</a>|
|KurrentDB|KurrentDB (formerly EventStoreDB)| 172.20.6.40| <a href="https://www.kurrent.io/" target="_blank" rel="noopener noreferrer">https://www.kurrent.io/</a>|
|InfluxDb|InfluxDB| 172.20.6.50| <a href="https://www.influxdata.com/" target="_blank" rel="noopener noreferrer">https://www.influxdata.com/</a>|
|MariaDb|MariaDB| 172.20.6.60| <a href="https://mariadb.org/" target="_blank" rel="noopener noreferrer">https://mariadb.org/</a>|
|MariaDb|Adminer| 172.20.6.61| <a href="https://www.adminer.org/" target="_blank" rel="noopener noreferrer">https://www.adminer.org/</a>|
|Milvus|Milvus etcd| 172.20.6.70| <a href="https://etcd.io/" target="_blank" rel="noopener noreferrer">https://etcd.io/</a>|
|Milvus|Milvus MinIO| 172.20.6.71| <a href="https://github.com/minio/minio" target="_blank" rel="noopener noreferrer">https://github.com/minio/minio</a>|
|Milvus|Milvus| 172.20.6.72| <a href="https://milvus.io/" target="_blank" rel="noopener noreferrer">https://milvus.io/</a>|
|MongoDB|MongoDB| 172.20.6.80| <a href="https://www.mongodb.com/" target="_blank" rel="noopener noreferrer">https://www.mongodb.com/</a>|
|MongoDB|Mongo Express| 172.20.6.81| <a href="https://github.com/mongo-express/mongo-express" target="_blank" rel="noopener noreferrer">https://github.com/mongo-express/mongo-express</a>|
|MSSQL|MSSQL| 172.20.6.90| <a href="https://www.microsoft.com/en-us/sql-server/" target="_blank" rel="noopener noreferrer">https://www.microsoft.com/en-us/sql-server/</a>|
|MySQL|MySQL| 172.20.6.100| <a href="https://www.mysql.com/" target="_blank" rel="noopener noreferrer">https://www.mysql.com/</a>|
|MySQL|phpMyAdmin| 172.20.6.101| <a href="https://www.phpmyadmin.net/" target="_blank" rel="noopener noreferrer">https://www.phpmyadmin.net/</a>|
|Neo4J|Neo4j| 172.20.6.110| <a href="https://neo4j.com/" target="_blank" rel="noopener noreferrer">https://neo4j.com/</a>|
|Oracle|Oracle| 172.20.6.120| <a href="https://www.oracle.com/database/" target="_blank" rel="noopener noreferrer">https://www.oracle.com/database/</a>|
|PostgreSQL|PostgreSQL (with pgvector)| 172.20.6.130| <a href="https://www.postgresql.org/" target="_blank" rel="noopener noreferrer">https://www.postgresql.org/</a>|
|PostgreSQL|pgAdmin4| 172.20.6.131| <a href="https://www.pgadmin.org/" target="_blank" rel="noopener noreferrer">https://www.pgadmin.org/</a>|
| *(.140-.149 free: Prometheus moved to Observability)*| | |
|Redis|Redis| 172.20.6.150| <a href="https://redis.io/" target="_blank" rel="noopener noreferrer">https://redis.io/</a>|
|RavenDB|RavenDB| 172.20.6.160| <a href="https://ravendb.net/" target="_blank" rel="noopener noreferrer">https://ravendb.net/</a>|
|CouchDB|CouchDB| 172.20.6.170| <a href="https://couchdb.apache.org/" target="_blank" rel="noopener noreferrer">https://couchdb.apache.org/</a>|
|CouchDB|CouchDB setup (one-shot)| 172.20.6.171| <a href="https://couchdb.apache.org/" target="_blank" rel="noopener noreferrer">https://couchdb.apache.org/</a>|
|Couchbase|Couchbase Server CE| 172.20.6.180| <a href="https://www.couchbase.com/" target="_blank" rel="noopener noreferrer">https://www.couchbase.com/</a>|
|Couchbase|Couchbase setup (one-shot)| 172.20.6.181| <a href="https://www.couchbase.com/" target="_blank" rel="noopener noreferrer">https://www.couchbase.com/</a>|
|Garnet|Garnet| 172.20.6.190| <a href="https://microsoft.github.io/garnet/" target="_blank" rel="noopener noreferrer">https://microsoft.github.io/garnet/</a>|
|Memcached|Memcached| 172.20.6.200| <a href="https://memcached.org/" target="_blank" rel="noopener noreferrer">https://memcached.org/</a>|
|Qdrant|Qdrant| 172.20.6.210| <a href="https://qdrant.tech/" target="_blank" rel="noopener noreferrer">https://qdrant.tech/</a>|
|ScyllaDB|ScyllaDB| 172.20.6.220| <a href="https://www.scylladb.com/" target="_blank" rel="noopener noreferrer">https://www.scylladb.com/</a>|
|CloudBeaver|CloudBeaver| 172.20.6.230| <a href="https://github.com/dbeaver/cloudbeaver" target="_blank" rel="noopener noreferrer">https://github.com/dbeaver/cloudbeaver</a>|
|TimescaleDB|TimescaleDB| 172.20.6.240| <a href="https://github.com/timescale/timescaledb" target="_blank" rel="noopener noreferrer">https://github.com/timescale/timescaledb</a>|
|Valkey|Valkey| 172.20.6.250| <a href="https://valkey.io/" target="_blank" rel="noopener noreferrer">https://valkey.io/</a>|

## Documentation (172.20.7.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Backstage|Backstage| 172.20.7.10| <a href="https://backstage.io/" target="_blank" rel="noopener noreferrer">https://backstage.io/</a>|
|Mediawiki|MediaWiki| 172.20.7.20| <a href="https://www.mediawiki.org/" target="_blank" rel="noopener noreferrer">https://www.mediawiki.org/</a>|
|WikiJs|Wiki.js DB setup (one-shot)| 172.20.7.30| <a href="https://js.wiki/" target="_blank" rel="noopener noreferrer">https://js.wiki/</a>|
|WikiJs|Wiki.js| 172.20.7.31| <a href="https://js.wiki/" target="_blank" rel="noopener noreferrer">https://js.wiki/</a>|
|BookStack|BookStack DB setup (one-shot)| 172.20.7.40| <a href="https://www.bookstackapp.com/" target="_blank" rel="noopener noreferrer">https://www.bookstackapp.com/</a>|
|BookStack|BookStack| 172.20.7.41| <a href="https://www.bookstackapp.com/" target="_blank" rel="noopener noreferrer">https://www.bookstackapp.com/</a>|
|Outline|Outline DB setup (one-shot)| 172.20.7.50| <a href="https://www.getoutline.com/" target="_blank" rel="noopener noreferrer">https://www.getoutline.com/</a>|
|Outline|Outline Redis| 172.20.7.51| <a href="https://redis.io/" target="_blank" rel="noopener noreferrer">https://redis.io/</a>|
|Outline|Dex (OIDC login for Outline)| 172.20.7.52| <a href="https://dexidp.io/" target="_blank" rel="noopener noreferrer">https://dexidp.io/</a>|
|Outline|Outline| 172.20.7.53| <a href="https://www.getoutline.com/" target="_blank" rel="noopener noreferrer">https://www.getoutline.com/</a>|
|Structurizr|Structurizr (local)| 172.20.7.60| <a href="https://structurizr.com/" target="_blank" rel="noopener noreferrer">https://structurizr.com/</a>|
|Kroki|Kroki| 172.20.7.70| <a href="https://kroki.io/" target="_blank" rel="noopener noreferrer">https://kroki.io/</a>|
|Kroki|Kroki Mermaid| 172.20.7.71| <a href="https://kroki.io/" target="_blank" rel="noopener noreferrer">https://kroki.io/</a>|
|Kroki|Kroki BPMN| 172.20.7.72| <a href="https://kroki.io/" target="_blank" rel="noopener noreferrer">https://kroki.io/</a>|
|Kroki|Kroki Excalidraw| 172.20.7.73| <a href="https://kroki.io/" target="_blank" rel="noopener noreferrer">https://kroki.io/</a>|
|DrawIo|draw.io| 172.20.7.80| <a href="https://www.drawio.com/" target="_blank" rel="noopener noreferrer">https://www.drawio.com/</a>|
|ApiDocs|Swagger UI| 172.20.7.90| <a href="https://swagger.io/tools/swagger-ui/" target="_blank" rel="noopener noreferrer">https://swagger.io/tools/swagger-ui/</a>|
|ApiDocs|Redoc| 172.20.7.91| <a href="https://redocly.com/redoc" target="_blank" rel="noopener noreferrer">https://redocly.com/redoc</a>|

## Email (172.20.8.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Mailpit|Mailpit| 172.20.8.10| <a href="https://mailpit.axllent.org/" target="_blank" rel="noopener noreferrer">https://mailpit.axllent.org/</a>|
|Smtp4dev|smtp4dev| 172.20.8.20| <a href="https://github.com/rnwood/smtp4dev" target="_blank" rel="noopener noreferrer">https://github.com/rnwood/smtp4dev</a>|

## IaC (172.20.9.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Terraform|Terraform| 172.20.9.10| <a href="https://developer.hashicorp.com/terraform" target="_blank" rel="noopener noreferrer">https://developer.hashicorp.com/terraform</a>|
|OpenTofu|OpenTofu| 172.20.9.20| <a href="https://opentofu.org/" target="_blank" rel="noopener noreferrer">https://opentofu.org/</a>|
|Atlantis|Atlantis setup (one-shot)| 172.20.9.30| <a href="https://www.runatlantis.io/" target="_blank" rel="noopener noreferrer">https://www.runatlantis.io/</a>|
|Atlantis|Atlantis| 172.20.9.31| <a href="https://www.runatlantis.io/" target="_blank" rel="noopener noreferrer">https://www.runatlantis.io/</a>|
|Semaphore|Semaphore DB setup (one-shot)| 172.20.9.40| <a href="https://semaphoreui.com/" target="_blank" rel="noopener noreferrer">https://semaphoreui.com/</a>|
|Semaphore|Semaphore UI| 172.20.9.41| <a href="https://semaphoreui.com/" target="_blank" rel="noopener noreferrer">https://semaphoreui.com/</a>|

## Messaging (172.20.10.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Kafka|Kafka| 172.20.10.10| <a href="https://kafka.apache.org/" target="_blank" rel="noopener noreferrer">https://kafka.apache.org/</a>|
|Kafka|Kafka UI| 172.20.10.11| <a href="https://github.com/kafbat/kafka-ui" target="_blank" rel="noopener noreferrer">https://github.com/kafbat/kafka-ui</a>|
|RabbitMQ|RabbitMQ| 172.20.10.20| <a href="https://www.rabbitmq.com/" target="_blank" rel="noopener noreferrer">https://www.rabbitmq.com/</a>|
|NATS|NATS (JetStream)| 172.20.10.30| <a href="https://nats.io/" target="_blank" rel="noopener noreferrer">https://nats.io/</a>|
|Mosquitto|Mosquitto (MQTT)| 172.20.10.40| <a href="https://mosquitto.org/" target="_blank" rel="noopener noreferrer">https://mosquitto.org/</a>|
|Artemis|Apache Artemis| 172.20.10.50| <a href="https://activemq.apache.org/components/artemis/" target="_blank" rel="noopener noreferrer">https://activemq.apache.org/components/artemis/</a>|
|Redpanda|Redpanda| 172.20.10.60| <a href="https://www.redpanda.com/" target="_blank" rel="noopener noreferrer">https://www.redpanda.com/</a>|
|Redpanda|Redpanda Console| 172.20.10.61| <a href="https://github.com/redpanda-data/console" target="_blank" rel="noopener noreferrer">https://github.com/redpanda-data/console</a>|
|Pulsar|Apache Pulsar (standalone)| 172.20.10.70| <a href="https://pulsar.apache.org/" target="_blank" rel="noopener noreferrer">https://pulsar.apache.org/</a>|
|Debezium|Debezium (Kafka Connect)| 172.20.10.80| <a href="https://debezium.io/" target="_blank" rel="noopener noreferrer">https://debezium.io/</a>|
|Apicurio|Apicurio DB setup (one-shot)| 172.20.10.90| <a href="https://www.apicur.io/registry/" target="_blank" rel="noopener noreferrer">https://www.apicur.io/registry/</a>|
|Apicurio|Apicurio Registry| 172.20.10.91| <a href="https://www.apicur.io/registry/" target="_blank" rel="noopener noreferrer">https://www.apicur.io/registry/</a>|
|Apicurio|Apicurio Registry UI| 172.20.10.92| <a href="https://www.apicur.io/registry/" target="_blank" rel="noopener noreferrer">https://www.apicur.io/registry/</a>|

## Observability (172.20.11.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|AspireDashboard|Aspire Dashboard| 172.20.11.10| <a href="https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/dashboard/standalone" target="_blank" rel="noopener noreferrer">https://learn.microsoft.com/en-us/dotnet/aspire/fundamentals/dashboard/standalone</a>|
|OpenTelemetry|OpenTelemetry Collector| 172.20.11.20| <a href="https://opentelemetry.io/docs/collector/" target="_blank" rel="noopener noreferrer">https://opentelemetry.io/docs/collector/</a>|
|OpenTelemetry|Tempo| 172.20.11.21| <a href="https://grafana.com/oss/tempo/" target="_blank" rel="noopener noreferrer">https://grafana.com/oss/tempo/</a>|
|OpenTelemetry|Loki| 172.20.11.22| <a href="https://grafana.com/oss/loki/" target="_blank" rel="noopener noreferrer">https://grafana.com/oss/loki/</a>|
|Prometheus|Prometheus| 172.20.11.30| <a href="https://prometheus.io/" target="_blank" rel="noopener noreferrer">https://prometheus.io/</a>|
|Prometheus|Prometheus Node Exporter| 172.20.11.31| <a href="https://github.com/prometheus/node_exporter" target="_blank" rel="noopener noreferrer">https://github.com/prometheus/node_exporter</a>|
|Prometheus|Prometheus Alertmanager| 172.20.11.32| <a href="https://prometheus.io/docs/alerting/latest/alertmanager/" target="_blank" rel="noopener noreferrer">https://prometheus.io/docs/alerting/latest/alertmanager/</a>|
|Jaeger|Jaeger v2| 172.20.11.40| <a href="https://www.jaegertracing.io/" target="_blank" rel="noopener noreferrer">https://www.jaegertracing.io/</a>|
|Pyroscope|Grafana Pyroscope| 172.20.11.50| <a href="https://grafana.com/oss/pyroscope/" target="_blank" rel="noopener noreferrer">https://grafana.com/oss/pyroscope/</a>|
|UptimeKuma|Uptime Kuma| 172.20.11.60| <a href="https://uptime.kuma.pet/" target="_blank" rel="noopener noreferrer">https://uptime.kuma.pet/</a>|
|cAdvisor|cAdvisor| 172.20.11.70| <a href="https://github.com/google/cadvisor" target="_blank" rel="noopener noreferrer">https://github.com/google/cadvisor</a>|
|OtelLgtm|grafana/otel-lgtm| 172.20.11.80| <a href="https://github.com/grafana/docker-otel-lgtm" target="_blank" rel="noopener noreferrer">https://github.com/grafana/docker-otel-lgtm</a>|
|SigNoz|SigNoz DB setup (one-shot)| 172.20.11.90| <a href="https://signoz.io/" target="_blank" rel="noopener noreferrer">https://signoz.io/</a>|
|SigNoz|SigNoz ClickHouse Keeper| 172.20.11.91| <a href="https://clickhouse.com/" target="_blank" rel="noopener noreferrer">https://clickhouse.com/</a>|
|SigNoz|SigNoz ClickHouse UDF setup (one-shot)| 172.20.11.92| <a href="https://signoz.io/" target="_blank" rel="noopener noreferrer">https://signoz.io/</a>|
|SigNoz|SigNoz ClickHouse| 172.20.11.93| <a href="https://clickhouse.com/" target="_blank" rel="noopener noreferrer">https://clickhouse.com/</a>|
|SigNoz|SigNoz schema migrator (one-shot)| 172.20.11.94| <a href="https://signoz.io/" target="_blank" rel="noopener noreferrer">https://signoz.io/</a>|
|SigNoz|SigNoz| 172.20.11.95| <a href="https://signoz.io/" target="_blank" rel="noopener noreferrer">https://signoz.io/</a>|
|SigNoz|SigNoz collector| 172.20.11.96| <a href="https://signoz.io/" target="_blank" rel="noopener noreferrer">https://signoz.io/</a>|

## Orchestration (172.20.12.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Kubernetes| *(no compose stack - block .10-.19 reserved)*| |
|Portainer|Portainer| 172.20.12.20| <a href="https://www.portainer.io/" target="_blank" rel="noopener noreferrer">https://www.portainer.io/</a>|
|Rancher|Rancher| 172.20.12.30| <a href="https://www.rancher.com/" target="_blank" rel="noopener noreferrer">https://www.rancher.com/</a>|
|K3s|K3s (Kubernetes) + Argo CD| 172.20.12.40| <a href="https://k3s.io/" target="_blank" rel="noopener noreferrer">https://k3s.io/</a>|
|K3s|K3s setup (one-shot: kubeconfig, DNS, Argo CD)| 172.20.12.41| <a href="https://k3s.io/" target="_blank" rel="noopener noreferrer">https://k3s.io/</a>|
|Headlamp|Headlamp| 172.20.12.50| <a href="https://headlamp.dev/" target="_blank" rel="noopener noreferrer">https://headlamp.dev/</a>|
|Nomad|HashiCorp Nomad| 172.20.12.60| <a href="https://www.nomadproject.io/" target="_blank" rel="noopener noreferrer">https://www.nomadproject.io/</a>|

## Packages (172.20.13.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Proget|ProGet| 172.20.13.10| <a href="https://inedo.com/proget" target="_blank" rel="noopener noreferrer">https://inedo.com/proget</a>|
|Nexus|Sonatype Nexus CE| 172.20.13.20| <a href="https://www.sonatype.com/products/sonatype-nexus-repository" target="_blank" rel="noopener noreferrer">https://www.sonatype.com/products/sonatype-nexus-repository</a>|
|Nexus|Nexus setup (one-shot)| 172.20.13.21| <a href="https://www.sonatype.com/products/sonatype-nexus-repository" target="_blank" rel="noopener noreferrer">https://www.sonatype.com/products/sonatype-nexus-repository</a>|
|BaGetter|BaGetter| 172.20.13.30| <a href="https://www.bagetter.com/" target="_blank" rel="noopener noreferrer">https://www.bagetter.com/</a>|
|Verdaccio|Verdaccio| 172.20.13.40| <a href="https://verdaccio.org/" target="_blank" rel="noopener noreferrer">https://verdaccio.org/</a>|

## RP-LB (172.20.14.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|HAProxy|HAProxy| 172.20.14.10| <a href="https://www.haproxy.org/" target="_blank" rel="noopener noreferrer">https://www.haproxy.org/</a>|
|NginxProxyManager|Nginx Proxy Manager| 172.20.14.20| <a href="https://nginxproxymanager.com/" target="_blank" rel="noopener noreferrer">https://nginxproxymanager.com/</a>|
|Traefik|Traefik| 172.20.14.30| <a href="https://traefik.io/traefik/" target="_blank" rel="noopener noreferrer">https://traefik.io/traefik/</a>|
|Caddy|Caddy| 172.20.14.40| <a href="https://caddyserver.com/" target="_blank" rel="noopener noreferrer">https://caddyserver.com/</a>|
|Yarp|YARP (.NET reverse proxy)| 172.20.14.50| <a href="https://github.com/dotnet/yarp" target="_blank" rel="noopener noreferrer">https://github.com/dotnet/yarp</a>|
|Envoy|Envoy| 172.20.14.60| <a href="https://www.envoyproxy.io/" target="_blank" rel="noopener noreferrer">https://www.envoyproxy.io/</a>|
|Kong|Kong Gateway (OSS, DB-less)| 172.20.14.70| <a href="https://konghq.com/products/kong-gateway" target="_blank" rel="noopener noreferrer">https://konghq.com/products/kong-gateway</a>|

## Scheduling (172.20.15.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Hangfire|Hangfire| 172.20.15.10| <a href="https://www.hangfire.io/" target="_blank" rel="noopener noreferrer">https://www.hangfire.io/</a>|
|Temporal|Temporal database setup (one-shot)| 172.20.15.20| <a href="https://temporal.io/" target="_blank" rel="noopener noreferrer">https://temporal.io/</a>|
|Temporal|Temporal schema setup (one-shot)| 172.20.15.21| <a href="https://temporal.io/" target="_blank" rel="noopener noreferrer">https://temporal.io/</a>|
|Temporal|Temporal server| 172.20.15.22| <a href="https://temporal.io/" target="_blank" rel="noopener noreferrer">https://temporal.io/</a>|
|Temporal|Temporal namespace setup (one-shot)| 172.20.15.23| <a href="https://temporal.io/" target="_blank" rel="noopener noreferrer">https://temporal.io/</a>|
|Temporal|Temporal UI| 172.20.15.24| <a href="https://temporal.io/" target="_blank" rel="noopener noreferrer">https://temporal.io/</a>|
|Airflow|Airflow database setup (one-shot)| 172.20.15.30| <a href="https://airflow.apache.org/" target="_blank" rel="noopener noreferrer">https://airflow.apache.org/</a>|
|Airflow|Airflow init (one-shot)| 172.20.15.31| <a href="https://airflow.apache.org/" target="_blank" rel="noopener noreferrer">https://airflow.apache.org/</a>|
|Airflow|Airflow API server| 172.20.15.32| <a href="https://airflow.apache.org/" target="_blank" rel="noopener noreferrer">https://airflow.apache.org/</a>|
|Airflow|Airflow scheduler| 172.20.15.33| <a href="https://airflow.apache.org/" target="_blank" rel="noopener noreferrer">https://airflow.apache.org/</a>|
|Airflow|Airflow DAG processor| 172.20.15.34| <a href="https://airflow.apache.org/" target="_blank" rel="noopener noreferrer">https://airflow.apache.org/</a>|
|Airflow|Airflow triggerer| 172.20.15.35| <a href="https://airflow.apache.org/" target="_blank" rel="noopener noreferrer">https://airflow.apache.org/</a>|
|Rundeck|Rundeck database setup (one-shot)| 172.20.15.40| <a href="https://www.rundeck.com/" target="_blank" rel="noopener noreferrer">https://www.rundeck.com/</a>|
|Rundeck|Rundeck| 172.20.15.41| <a href="https://www.rundeck.com/" target="_blank" rel="noopener noreferrer">https://www.rundeck.com/</a>|
|N8n|n8n database setup (one-shot)| 172.20.15.50| <a href="https://n8n.io/" target="_blank" rel="noopener noreferrer">https://n8n.io/</a>|
|N8n|n8n| 172.20.15.51| <a href="https://n8n.io/" target="_blank" rel="noopener noreferrer">https://n8n.io/</a>|
|N8n|n8n owner setup (one-shot)| 172.20.15.52| <a href="https://n8n.io/" target="_blank" rel="noopener noreferrer">https://n8n.io/</a>|
|N8n|n8n task runners| 172.20.15.53| <a href="https://n8n.io/" target="_blank" rel="noopener noreferrer">https://n8n.io/</a>|
|Camunda|Camunda 8 Orchestration Cluster| 172.20.15.60| <a href="https://camunda.com/" target="_blank" rel="noopener noreferrer">https://camunda.com/</a>|
|Camunda|Camunda 8 Connectors| 172.20.15.61| <a href="https://camunda.com/" target="_blank" rel="noopener noreferrer">https://camunda.com/</a>|
|NodeRed|Node-RED| 172.20.15.70| <a href="https://nodered.org/" target="_blank" rel="noopener noreferrer">https://nodered.org/</a>|

## Search (172.20.16.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|ElasticSearch|Elasticsearch setup (one-shot)| 172.20.16.10| <a href="https://www.elastic.co/elasticsearch" target="_blank" rel="noopener noreferrer">https://www.elastic.co/elasticsearch</a>|
|ElasticSearch|Elasticsearch (es01)| 172.20.16.11| <a href="https://www.elastic.co/elasticsearch" target="_blank" rel="noopener noreferrer">https://www.elastic.co/elasticsearch</a>|
|ElasticSearch|Kibana| 172.20.16.12| <a href="https://www.elastic.co/kibana" target="_blank" rel="noopener noreferrer">https://www.elastic.co/kibana</a>|
|ElasticSearch|Metricbeat| 172.20.16.13| <a href="https://www.elastic.co/beats/metricbeat" target="_blank" rel="noopener noreferrer">https://www.elastic.co/beats/metricbeat</a>|
|ElasticSearch|Filebeat| 172.20.16.14| <a href="https://www.elastic.co/beats/filebeat" target="_blank" rel="noopener noreferrer">https://www.elastic.co/beats/filebeat</a>|
|ElasticSearch|Logstash| 172.20.16.15| <a href="https://www.elastic.co/logstash" target="_blank" rel="noopener noreferrer">https://www.elastic.co/logstash</a>|
|OpenSearch|OpenSearch node 1| 172.20.16.20| <a href="https://opensearch.org/" target="_blank" rel="noopener noreferrer">https://opensearch.org/</a>|
|OpenSearch|OpenSearch node 2| 172.20.16.21| <a href="https://opensearch.org/" target="_blank" rel="noopener noreferrer">https://opensearch.org/</a>|
|OpenSearch|OpenSearch Dashboards| 172.20.16.22| <a href="https://opensearch.org/" target="_blank" rel="noopener noreferrer">https://opensearch.org/</a>|
|Meilisearch|Meilisearch| 172.20.16.30| <a href="https://www.meilisearch.com/" target="_blank" rel="noopener noreferrer">https://www.meilisearch.com/</a>|
|Typesense|Typesense| 172.20.16.40| <a href="https://typesense.org/" target="_blank" rel="noopener noreferrer">https://typesense.org/</a>|
|Solr|Apache Solr| 172.20.16.50| <a href="https://solr.apache.org/" target="_blank" rel="noopener noreferrer">https://solr.apache.org/</a>|

## Security (172.20.17.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Vault|Vault| 172.20.17.10| <a href="https://www.vaultproject.io/" target="_blank" rel="noopener noreferrer">https://www.vaultproject.io/</a>|
|OpenBao|OpenBao| 172.20.17.20| <a href="https://openbao.org/" target="_blank" rel="noopener noreferrer">https://openbao.org/</a>|
|StepCa|step-ca| 172.20.17.30| <a href="https://smallstep.com/docs/step-ca/" target="_blank" rel="noopener noreferrer">https://smallstep.com/docs/step-ca/</a>|
|Zap|ZAP (headless proxy + API)| 172.20.17.40| <a href="https://www.zaproxy.org/" target="_blank" rel="noopener noreferrer">https://www.zaproxy.org/</a>|
|Zap|ZAP desktop UI (profile "ui")| 172.20.17.41| <a href="https://www.zaproxy.org/" target="_blank" rel="noopener noreferrer">https://www.zaproxy.org/</a>|
|Infisical|Infisical database setup (one-shot)| 172.20.17.50| <a href="https://infisical.com/" target="_blank" rel="noopener noreferrer">https://infisical.com/</a>|
|Infisical|Infisical| 172.20.17.51| <a href="https://infisical.com/" target="_blank" rel="noopener noreferrer">https://infisical.com/</a>|
|Infisical|Infisical admin setup (one-shot)| 172.20.17.52| <a href="https://infisical.com/" target="_blank" rel="noopener noreferrer">https://infisical.com/</a>|

## SIEM (172.20.18.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Wazuh|Wazuh certs generator (one-shot)| 172.20.18.10| <a href="https://wazuh.com/" target="_blank" rel="noopener noreferrer">https://wazuh.com/</a>|
|Wazuh|Wazuh Manager| 172.20.18.11| <a href="https://wazuh.com/" target="_blank" rel="noopener noreferrer">https://wazuh.com/</a>|
|Wazuh|Wazuh Indexer| 172.20.18.12| <a href="https://wazuh.com/" target="_blank" rel="noopener noreferrer">https://wazuh.com/</a>|
|Wazuh|Wazuh Dashboard| 172.20.18.13| <a href="https://wazuh.com/" target="_blank" rel="noopener noreferrer">https://wazuh.com/</a>|
|Graylog|Graylog MongoDB| 172.20.18.20| <a href="https://www.mongodb.com/" target="_blank" rel="noopener noreferrer">https://www.mongodb.com/</a>|
|Graylog|Graylog Data Node| 172.20.18.21| <a href="https://graylog.org/" target="_blank" rel="noopener noreferrer">https://graylog.org/</a>|
|Graylog|Graylog| 172.20.18.22| <a href="https://graylog.org/" target="_blank" rel="noopener noreferrer">https://graylog.org/</a>|

## SourceControl (172.20.19.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Gitea|Gitea| 172.20.19.10| <a href="https://about.gitea.com/" target="_blank" rel="noopener noreferrer">https://about.gitea.com/</a>|
|Gitea|Gitea Actions runner| 172.20.19.11| <a href="https://about.gitea.com/" target="_blank" rel="noopener noreferrer">https://about.gitea.com/</a>|
|Forgejo|Forgejo| 172.20.19.20| <a href="https://forgejo.org/" target="_blank" rel="noopener noreferrer">https://forgejo.org/</a>|
|Forgejo|Forgejo admin + runner token setup (one-shot)| 172.20.19.21| <a href="https://forgejo.org/" target="_blank" rel="noopener noreferrer">https://forgejo.org/</a>|
|Forgejo|Forgejo Actions runner| 172.20.19.22| <a href="https://forgejo.org/" target="_blank" rel="noopener noreferrer">https://forgejo.org/</a>|
|GitLab|GitLab CE| 172.20.19.30| <a href="https://about.gitlab.com/" target="_blank" rel="noopener noreferrer">https://about.gitlab.com/</a>|
|OneDev|OneDev| 172.20.19.40| <a href="https://onedev.io/" target="_blank" rel="noopener noreferrer">https://onedev.io/</a>|

## Visualization (172.20.20.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Grafana|Grafana| 172.20.20.10| <a href="https://grafana.com/oss/grafana/" target="_blank" rel="noopener noreferrer">https://grafana.com/oss/grafana/</a>|
|Metabase|Metabase database setup (one-shot)| 172.20.20.20| <a href="https://www.metabase.com/" target="_blank" rel="noopener noreferrer">https://www.metabase.com/</a>|
|Metabase|Metabase| 172.20.20.21| <a href="https://www.metabase.com/" target="_blank" rel="noopener noreferrer">https://www.metabase.com/</a>|
|Metabase|Metabase admin setup (one-shot)| 172.20.20.22| <a href="https://www.metabase.com/" target="_blank" rel="noopener noreferrer">https://www.metabase.com/</a>|
|Superset|Superset database setup (one-shot)| 172.20.20.30| <a href="https://superset.apache.org/" target="_blank" rel="noopener noreferrer">https://superset.apache.org/</a>|
|Superset|Superset init (one-shot)| 172.20.20.31| <a href="https://superset.apache.org/" target="_blank" rel="noopener noreferrer">https://superset.apache.org/</a>|
|Superset|Superset| 172.20.20.32| <a href="https://superset.apache.org/" target="_blank" rel="noopener noreferrer">https://superset.apache.org/</a>|
|Redash|Redash database setup (one-shot)| 172.20.20.40| <a href="https://redash.io/" target="_blank" rel="noopener noreferrer">https://redash.io/</a>|
|Redash|Redash init (one-shot)| 172.20.20.41| <a href="https://redash.io/" target="_blank" rel="noopener noreferrer">https://redash.io/</a>|
|Redash|Redash server| 172.20.20.42| <a href="https://redash.io/" target="_blank" rel="noopener noreferrer">https://redash.io/</a>|
|Redash|Redash scheduler| 172.20.20.43| <a href="https://redash.io/" target="_blank" rel="noopener noreferrer">https://redash.io/</a>|
|Redash|Redash worker| 172.20.20.44| <a href="https://redash.io/" target="_blank" rel="noopener noreferrer">https://redash.io/</a>|

## WebServers (172.20.21.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Apache|Apache| 172.20.21.10| <a href="https://httpd.apache.org/" target="_blank" rel="noopener noreferrer">https://httpd.apache.org/</a>|
|Nginx|Nginx| 172.20.21.20| <a href="https://nginx.org/" target="_blank" rel="noopener noreferrer">https://nginx.org/</a>|
|Nginx|Nginx UI| 172.20.21.21| <a href="https://nginxui.com/" target="_blank" rel="noopener noreferrer">https://nginxui.com/</a>|

## CI-CD (172.20.22.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Jenkins|Jenkins| 172.20.22.10| <a href="https://www.jenkins.io/" target="_blank" rel="noopener noreferrer">https://www.jenkins.io/</a>|
|TeamCity|TeamCity server| 172.20.22.20| <a href="https://www.jetbrains.com/teamcity/" target="_blank" rel="noopener noreferrer">https://www.jetbrains.com/teamcity/</a>|
|TeamCity|TeamCity build agent| 172.20.22.21| <a href="https://www.jetbrains.com/teamcity/" target="_blank" rel="noopener noreferrer">https://www.jetbrains.com/teamcity/</a>|
|Woodpecker|Woodpecker Gitea OAuth2 setup (one-shot)| 172.20.22.30| <a href="https://woodpecker-ci.org/" target="_blank" rel="noopener noreferrer">https://woodpecker-ci.org/</a>|
|Woodpecker|Woodpecker server| 172.20.22.31| <a href="https://woodpecker-ci.org/" target="_blank" rel="noopener noreferrer">https://woodpecker-ci.org/</a>|
|Woodpecker|Woodpecker agent| 172.20.22.32| <a href="https://woodpecker-ci.org/" target="_blank" rel="noopener noreferrer">https://woodpecker-ci.org/</a>|

## Testing (172.20.23.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|WireMock|WireMock| 172.20.23.10| <a href="https://wiremock.org/" target="_blank" rel="noopener noreferrer">https://wiremock.org/</a>|
|Microcks|Microcks (uber)| 172.20.23.20| <a href="https://microcks.io/" target="_blank" rel="noopener noreferrer">https://microcks.io/</a>|
|Microcks|Microcks artifact import (one-shot)| 172.20.23.21| <a href="https://microcks.io/" target="_blank" rel="noopener noreferrer">https://microcks.io/</a>|
|Mockoon|Mockoon CLI| 172.20.23.30| <a href="https://mockoon.com/" target="_blank" rel="noopener noreferrer">https://mockoon.com/</a>|
|K6|k6 (one-shot test run)| 172.20.23.40| <a href="https://k6.io/" target="_blank" rel="noopener noreferrer">https://k6.io/</a>|
|Toxiproxy|Toxiproxy| 172.20.23.50| <a href="https://github.com/Shopify/toxiproxy" target="_blank" rel="noopener noreferrer">https://github.com/Shopify/toxiproxy</a>|
|SeleniumGrid|Selenium hub| 172.20.23.60| <a href="https://www.selenium.dev/documentation/grid/" target="_blank" rel="noopener noreferrer">https://www.selenium.dev/documentation/grid/</a>|
|SeleniumGrid|Selenium Chrome node| 172.20.23.61| <a href="https://www.selenium.dev/documentation/grid/" target="_blank" rel="noopener noreferrer">https://www.selenium.dev/documentation/grid/</a>|
|SeleniumGrid|Selenium Firefox node| 172.20.23.62| <a href="https://www.selenium.dev/documentation/grid/" target="_blank" rel="noopener noreferrer">https://www.selenium.dev/documentation/grid/</a>|
|SeleniumGrid|Selenium Edge node| 172.20.23.63| <a href="https://www.selenium.dev/documentation/grid/" target="_blank" rel="noopener noreferrer">https://www.selenium.dev/documentation/grid/</a>|
|PactBroker|Pact Broker database setup (one-shot)| 172.20.23.70| <a href="https://docs.pact.io/pact_broker" target="_blank" rel="noopener noreferrer">https://docs.pact.io/pact_broker</a>|
|PactBroker|Pact Broker| 172.20.23.71| <a href="https://docs.pact.io/pact_broker" target="_blank" rel="noopener noreferrer">https://docs.pact.io/pact_broker</a>|
|Hoppscotch|Hoppscotch database setup (one-shot)| 172.20.23.80| <a href="https://hoppscotch.io/" target="_blank" rel="noopener noreferrer">https://hoppscotch.io/</a>|
|Hoppscotch|Hoppscotch migrations (one-shot)| 172.20.23.81| <a href="https://hoppscotch.io/" target="_blank" rel="noopener noreferrer">https://hoppscotch.io/</a>|
|Hoppscotch|Hoppscotch| 172.20.23.82| <a href="https://hoppscotch.io/" target="_blank" rel="noopener noreferrer">https://hoppscotch.io/</a>|
|Hoppscotch|Hoppscotch onboarding (one-shot)| 172.20.23.83| <a href="https://hoppscotch.io/" target="_blank" rel="noopener noreferrer">https://hoppscotch.io/</a>|

## FeatureFlags (172.20.24.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Unleash|Unleash database setup (one-shot)| 172.20.24.10| <a href="https://www.getunleash.io/" target="_blank" rel="noopener noreferrer">https://www.getunleash.io/</a>|
|Unleash|Unleash| 172.20.24.11| <a href="https://www.getunleash.io/" target="_blank" rel="noopener noreferrer">https://www.getunleash.io/</a>|
|Flagsmith|Flagsmith database setup (one-shot)| 172.20.24.20| <a href="https://www.flagsmith.com/" target="_blank" rel="noopener noreferrer">https://www.flagsmith.com/</a>|
|Flagsmith|Flagsmith| 172.20.24.21| <a href="https://www.flagsmith.com/" target="_blank" rel="noopener noreferrer">https://www.flagsmith.com/</a>|
|Flagsmith|Flagsmith admin + environments setup (one-shot)| 172.20.24.22| <a href="https://www.flagsmith.com/" target="_blank" rel="noopener noreferrer">https://www.flagsmith.com/</a>|
|GrowthBook|GrowthBook MongoDB 8.0| 172.20.24.30| <a href="https://www.mongodb.com/" target="_blank" rel="noopener noreferrer">https://www.mongodb.com/</a>|
|GrowthBook|GrowthBook| 172.20.24.31| <a href="https://www.growthbook.io/" target="_blank" rel="noopener noreferrer">https://www.growthbook.io/</a>|
|GrowthBook|GrowthBook first-time setup (one-shot)| 172.20.24.32| <a href="https://www.growthbook.io/" target="_blank" rel="noopener noreferrer">https://www.growthbook.io/</a>|
|Flagd|flagd| 172.20.24.40| <a href="https://flagd.dev/" target="_blank" rel="noopener noreferrer">https://flagd.dev/</a>|
|Consul|Consul server| 172.20.24.50| <a href="https://www.consul.io/" target="_blank" rel="noopener noreferrer">https://www.consul.io/</a>|
|Consul|Consul KV seed (one-shot)| 172.20.24.51| <a href="https://www.consul.io/" target="_blank" rel="noopener noreferrer">https://www.consul.io/</a>|

## ObjectStorage (172.20.25.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|RustFS|RustFS| 172.20.25.10| <a href="https://rustfs.com/" target="_blank" rel="noopener noreferrer">https://rustfs.com/</a>|
|RustFS|RustFS bucket setup (one-shot)| 172.20.25.11| <a href="https://rustfs.com/" target="_blank" rel="noopener noreferrer">https://rustfs.com/</a>|
|SeaweedFS|SeaweedFS (weed mini)| 172.20.25.20| <a href="https://github.com/seaweedfs/seaweedfs" target="_blank" rel="noopener noreferrer">https://github.com/seaweedfs/seaweedfs</a>|
|Garage|Garage| 172.20.25.30| <a href="https://garagehq.deuxfleurs.fr/" target="_blank" rel="noopener noreferrer">https://garagehq.deuxfleurs.fr/</a>|
|Garage|Garage layout/key/bucket setup (one-shot)| 172.20.25.31| <a href="https://garagehq.deuxfleurs.fr/" target="_blank" rel="noopener noreferrer">https://garagehq.deuxfleurs.fr/</a>|
|Garage|Garage web UI| 172.20.25.32| <a href="https://github.com/khairul169/garage-webui" target="_blank" rel="noopener noreferrer">https://github.com/khairul169/garage-webui</a>|

## ServiceMesh (172.20.26.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Dapr|Dapr placement| 172.20.26.10| <a href="https://dapr.io/" target="_blank" rel="noopener noreferrer">https://dapr.io/</a>|
|Dapr|Dapr scheduler| 172.20.26.11| <a href="https://dapr.io/" target="_blank" rel="noopener noreferrer">https://dapr.io/</a>|
|Dapr|Dapr dashboard| 172.20.26.12| <a href="https://github.com/dapr/dashboard" target="_blank" rel="noopener noreferrer">https://github.com/dapr/dashboard</a>|
|Dapr|Dapr sidecar (daprd for an app on the host)| 172.20.26.20| <a href="https://dapr.io/" target="_blank" rel="noopener noreferrer">https://dapr.io/</a>|

## AI (172.20.27.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Ollama|Ollama| 172.20.27.10| <a href="https://ollama.com/" target="_blank" rel="noopener noreferrer">https://ollama.com/</a>|
|Ollama|Ollama model pull (one-shot)| 172.20.27.11| <a href="https://ollama.com/" target="_blank" rel="noopener noreferrer">https://ollama.com/</a>|
|OpenWebUI|Open WebUI| 172.20.27.20| <a href="https://openwebui.com/" target="_blank" rel="noopener noreferrer">https://openwebui.com/</a>|
|LiteLLM|LiteLLM database setup (one-shot)| 172.20.27.30| <a href="https://www.litellm.ai/" target="_blank" rel="noopener noreferrer">https://www.litellm.ai/</a>|
|LiteLLM|LiteLLM proxy| 172.20.27.31| <a href="https://www.litellm.ai/" target="_blank" rel="noopener noreferrer">https://www.litellm.ai/</a>|
|Langfuse|Langfuse database setup (one-shot)| 172.20.27.40| <a href="https://langfuse.com/" target="_blank" rel="noopener noreferrer">https://langfuse.com/</a>|
|Langfuse|Langfuse S3 bucket setup (one-shot)| 172.20.27.41| <a href="https://langfuse.com/" target="_blank" rel="noopener noreferrer">https://langfuse.com/</a>|
|Langfuse|Langfuse ClickHouse| 172.20.27.42| <a href="https://clickhouse.com/" target="_blank" rel="noopener noreferrer">https://clickhouse.com/</a>|
|Langfuse|Langfuse web| 172.20.27.43| <a href="https://langfuse.com/" target="_blank" rel="noopener noreferrer">https://langfuse.com/</a>|
|Langfuse|Langfuse worker| 172.20.27.44| <a href="https://langfuse.com/" target="_blank" rel="noopener noreferrer">https://langfuse.com/</a>|

## DataIntegration (172.20.28.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|NiFi|Apache NiFi| 172.20.28.10| <a href="https://nifi.apache.org/" target="_blank" rel="noopener noreferrer">https://nifi.apache.org/</a>|
|NiFi|NiFi conf setup (one-shot)| 172.20.28.11| <a href="https://nifi.apache.org/" target="_blank" rel="noopener noreferrer">https://nifi.apache.org/</a>|
|Airbyte|Airbyte database setup (one-shot)| 172.20.28.20| <a href="https://airbyte.com/" target="_blank" rel="noopener noreferrer">https://airbyte.com/</a>|
|Airbyte|Airbyte Helm install into K3s (one-shot)| 172.20.28.21| <a href="https://airbyte.com/" target="_blank" rel="noopener noreferrer">https://airbyte.com/</a>|
|Airbyte|Airbyte proxy (localhost:8154 -> K3s NodePort 30081)| 172.20.28.22| <a href="https://airbyte.com/" target="_blank" rel="noopener noreferrer">https://airbyte.com/</a>|

## Collaboration (172.20.29.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Mattermost|Mattermost database setup (one-shot)| 172.20.29.10| <a href="https://mattermost.com/" target="_blank" rel="noopener noreferrer">https://mattermost.com/</a>|
|Mattermost|Mattermost| 172.20.29.11| <a href="https://mattermost.com/" target="_blank" rel="noopener noreferrer">https://mattermost.com/</a>|
|Mattermost|Mattermost admin/team setup (one-shot)| 172.20.29.12| <a href="https://mattermost.com/" target="_blank" rel="noopener noreferrer">https://mattermost.com/</a>|
|RocketChat|Rocket.Chat MongoDB (replica set)| 172.20.29.20| <a href="https://www.mongodb.com/" target="_blank" rel="noopener noreferrer">https://www.mongodb.com/</a>|
|RocketChat|Rocket.Chat replica set init (one-shot)| 172.20.29.21| <a href="https://www.rocket.chat/" target="_blank" rel="noopener noreferrer">https://www.rocket.chat/</a>|
|RocketChat|Rocket.Chat| 172.20.29.22| <a href="https://www.rocket.chat/" target="_blank" rel="noopener noreferrer">https://www.rocket.chat/</a>|
|Plane|Plane database setup (one-shot)| 172.20.29.30| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane S3 store (RustFS)| 172.20.29.31| <a href="https://rustfs.com/" target="_blank" rel="noopener noreferrer">https://rustfs.com/</a>|
|Plane|Plane migrator (one-shot)| 172.20.29.32| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane API| 172.20.29.33| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane worker| 172.20.29.34| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane beat worker| 172.20.29.35| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane web| 172.20.29.36| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane space| 172.20.29.37| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane admin (god mode)| 172.20.29.38| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane live| 172.20.29.39| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane proxy| 172.20.29.40| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane admin setup (one-shot)| 172.20.29.41| <a href="https://plane.so/" target="_blank" rel="noopener noreferrer">https://plane.so/</a>|
|Plane|Plane RabbitMQ broker| 172.20.29.42| <a href="https://www.rabbitmq.com/" target="_blank" rel="noopener noreferrer">https://www.rabbitmq.com/</a>|

## DevTools (172.20.30.x)
|Folder|Name|IP Address|URL|
|:----------|:----------|:----------|:----------|
|Homepage|Homepage| 172.20.30.10| <a href="https://gethomepage.dev/" target="_blank" rel="noopener noreferrer">https://gethomepage.dev/</a>|
|Homarr|Homarr| 172.20.30.20| <a href="https://homarr.dev/" target="_blank" rel="noopener noreferrer">https://homarr.dev/</a>|
|Homarr|Homarr admin/onboarding setup (one-shot)| 172.20.30.21| <a href="https://homarr.dev/" target="_blank" rel="noopener noreferrer">https://homarr.dev/</a>|
|ITTools|IT-Tools| 172.20.30.30| <a href="https://it-tools.tech/" target="_blank" rel="noopener noreferrer">https://it-tools.tech/</a>|
|CyberChef|CyberChef| 172.20.30.40| <a href="https://gchq.github.io/CyberChef/" target="_blank" rel="noopener noreferrer">https://gchq.github.io/CyberChef/</a>|
|CodeServer|code-server (.NET SDK)| 172.20.30.50| <a href="https://coder.com/docs/code-server" target="_blank" rel="noopener noreferrer">https://coder.com/docs/code-server</a>|
