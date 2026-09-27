# Docker-Scripts
Collection of Docker and Docker Compose scripts

## Getting started
1. `CreateNetwork.bat` / `CreateNetwork.sh` - creates the shared `GroupNetwork` (192.168.16.0/24) every stack attaches to.
2. `CreateVolumes.bat` / `CreateVolumes.sh` - creates the host folders behind the bind-mounted volumes.
3. `cd <Category>/<Tool>` then `docker compose up -d`.

Each stack's `.env` sets `ROOT_VOLUME_DIR=D:`. On Linux/macOS export `ROOT_VOLUME_DIR=$HOME` in your shell - a shell variable overrides the `.env` value.

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
## Global
|Name|IP Address|
|:----------|:----------|
|Gateway    | 192.168.16.1|

## Analytics
|Name|IP Address|
|:----------|:----------|
|Apache Spark| 192.168.16.190|
|Apache Spark Worker| 192.168.16.192|
|Seq| 192.168.16.191|

## Authentication
|Name|IP Address|
|:----------|:----------|
|SuperTokens| 192.168.16.211|

## CodeAnalysis
|Name|IP Address|
|:----------|:----------|
|Sonarqube| 192.168.16.170|

## Containerization
|Name|IP Address|
|:----------|:----------|
|Docker Registry| 192.168.16.180|
|Docker Registry UI| 192.168.16.181|

## Databases
|Name|IP Address|
|:----------|:----------|
|Adminer| 192.168.16.23|
|Apache Cassandra| 192.168.16.10|
|ClickHouse| 192.168.16.29|
|Cockroach DB| 192.168.16.11|
|EventStore DB| 192.168.16.21|
|Influx DB| 192.168.16.12|
|Maria DB| 192.168.16.22|
|Milvus etcd| 192.168.16.40|
|Milvus minio| 192.168.16.41|
|Milvus milvus| 192.168.16.42|
|Mongo DB| 192.168.16.13|
|Mongo Express| 192.168.16.24|
|MSSQL| 192.168.16.14|
|MySQL| 192.168.16.15|
|myphpadmin| 192.168.16.20|
|Neo4J| 192.168.16.16|
|Oracle| 192.168.16.25|
|PostgreSQL| 192.168.16.17|
|Prometheus| 192.168.16.26|
|Prometheus Node Exporter| 192.168.16.27|
|Prometheus Alert Manager| 192.168.16.28|
|pgAdmin4| 192.168.16.18|
|Redis| 192.168.16.19|

## Documentation
|Name|IP Address|
|:----------|:----------|
|Backstage| 192.168.16.30|
|Mediawiki| 192.168.16.31|

## IaC
|Name|IP Address|
|:----------|:----------|
|Terraform| 192.168.16.50|
|gaia| 192.168.16.51|
|gaiarunner| 192.168.16.52|
|gaia-mongo| 192.168.16.53|

## Messaging
|Name|IP Address|
|:----------|:----------|
|Kafka| 192.168.16.70|
|RabbitMQ| 192.168.16.72|
|Kafka UI| 192.168.16.73|

## Orchestration
|Name|IP Address|
|:----------|:----------|
|Kubernetes| 192.168.16.90|
|Rancher| 192.168.16.91|
|Portainer| 192.168.16.92|

## Packages
|Name|IP Address|
|:----------|:----------|
|ProGet| 192.168.16.200|

## Reverse Proxy / Load Balancing
|Name|IP Address|
|:----------|:----------|
|HAProxy| 192.168.16.160|
|Nginx Proxy Manager| 192.168.16.161|

## Scheduling
|Name|IP Address|
|:----------|:----------|
|Hangfire| 192.168.16.210|

## Search
|Name|IP Address|
|:----------|:----------|
|Elasticsearch setup (one-shot)| 192.168.16.150|
|es01| 192.168.16.151|
|Kibana| 192.168.16.152|
|Metricbeat| 192.168.16.153|
|Filebeat| 192.168.16.154|
|Logstash| 192.168.16.155|
|OpenSearchNode1| 192.168.16.156|
|OpenSearchNode2| 192.168.16.157|
|OpenSearchDashboard| 192.168.16.158|

## Visualization
|Name|IP Address|
|:----------|:----------|
|Grafana| 192.168.16.110|

## Web Servers
|Name|IP Address|
|:----------|:----------|
|Nginx| 192.168.16.130|
|NginxUI| 192.168.16.131|
|Apache| 192.168.16.132|
