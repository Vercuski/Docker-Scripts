#!/usr/bin/env bash
# Creates the host folders used by the bind-mounted volumes.
# ROOT defaults to $HOME; on Linux run compose with ROOT_VOLUME_DIR=$HOME (a shell variable overrides the .env value).
set -euo pipefail
ROOT="${ROOT_VOLUME_DIR:-$HOME}"

mkdir -p "$ROOT/docker/volumes/Analytics/ApacheSpark/data"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheSpark/apps"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheSpark/logs"
mkdir -p "$ROOT/docker/volumes/Analytics/Seq/data"

mkdir -p "$ROOT/docker/volumes/CloudEmulators/Azurite/data"
mkdir -p "$ROOT/docker/volumes/CloudEmulators/AzureCosmosDb/data"

mkdir -p "$ROOT/docker/volumes/CodeAnalysis/SonarQube/data"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/SonarQube/extensions"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/SonarQube/logs"

mkdir -p "$ROOT/docker/volumes/Containerization/DockerRegistry/data"

mkdir -p "$ROOT/docker/volumes/Databases/ApacheCassandra"
mkdir -p "$ROOT/docker/volumes/Databases/ClickHouse/data"
mkdir -p "$ROOT/docker/volumes/Databases/ClickHouse/logs"
mkdir -p "$ROOT/docker/volumes/Databases/CockroachDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/EventStoreDb/data"
mkdir -p "$ROOT/docker/volumes/Databases/EventStoreDb/logs"
mkdir -p "$ROOT/docker/volumes/Databases/InfluxDb/config"
mkdir -p "$ROOT/docker/volumes/Databases/InfluxDb/data"
mkdir -p "$ROOT/docker/volumes/Databases/MariaDB/Backup"
mkdir -p "$ROOT/docker/volumes/Databases/MariaDB/Data"
mkdir -p "$ROOT/docker/volumes/Databases/Milvus/milvus"
mkdir -p "$ROOT/docker/volumes/Databases/Milvus/etcd"
mkdir -p "$ROOT/docker/volumes/Databases/Milvus/minio"
mkdir -p "$ROOT/docker/volumes/Databases/MongoDb/data"
mkdir -p "$ROOT/docker/volumes/Databases/MSSQL/data"
mkdir -p "$ROOT/docker/volumes/Databases/MSSQL/log"
mkdir -p "$ROOT/docker/volumes/Databases/MSSQL/secrets"
mkdir -p "$ROOT/docker/volumes/Databases/MySQL"
mkdir -p "$ROOT/docker/volumes/Databases/Neo4J/data"
mkdir -p "$ROOT/docker/volumes/Databases/Neo4J/logs"
mkdir -p "$ROOT/docker/volumes/Databases/Neo4J/import"
mkdir -p "$ROOT/docker/volumes/Databases/Neo4J/plugins"
mkdir -p "$ROOT/docker/volumes/Databases/Oracle/Data"
mkdir -p "$ROOT/docker/volumes/Databases/Oracle/Backup"
mkdir -p "$ROOT/docker/volumes/Databases/PostgreSQL/Data"
mkdir -p "$ROOT/docker/volumes/Databases/PostgreSQL/pgadmin4data"
mkdir -p "$ROOT/docker/volumes/Databases/Prometheus/prometheus_data"
mkdir -p "$ROOT/docker/volumes/Databases/Prometheus/alertmanager"
mkdir -p "$ROOT/docker/volumes/Databases/Redis/cache"

mkdir -p "$ROOT/docker/volumes/Documentation/Mediawiki/html"

mkdir -p "$ROOT/docker/volumes/Email/Mailpit/data"

mkdir -p "$ROOT/docker/volumes/IaC/Terraform/data"

mkdir -p "$ROOT/docker/volumes/Messaging/Kafka/Kafka/data/"
mkdir -p "$ROOT/docker/volumes/Messaging/RabbitMQ/data"
mkdir -p "$ROOT/docker/volumes/Messaging/RabbitMQ/log"

mkdir -p "$ROOT/docker/volumes/Observability/OpenTelemetry/tempo"
mkdir -p "$ROOT/docker/volumes/Observability/OpenTelemetry/loki"

mkdir -p "$ROOT/docker/volumes/Orchestration/Rancher/data"
mkdir -p "$ROOT/docker/volumes/Orchestration/Portainer/data"

mkdir -p "$ROOT/docker/volumes/Packages/ProGet/packages"
mkdir -p "$ROOT/docker/volumes/Packages/ProGet/ssl"

mkdir -p "$ROOT/docker/volumes/RP-LB/NginxProxyManager/data"
mkdir -p "$ROOT/docker/volumes/RP-LB/NginxProxyManager/letsencrypt"

mkdir -p "$ROOT/docker/volumes/Search/OpenSearch/node1/"
mkdir -p "$ROOT/docker/volumes/Search/OpenSearch/node2/"
mkdir -p "$ROOT/docker/volumes/Search/ElasticSearch/certs"
mkdir -p "$ROOT/docker/volumes/Search/ElasticSearch/esdata01"
mkdir -p "$ROOT/docker/volumes/Search/ElasticSearch/kibanadata"
mkdir -p "$ROOT/docker/volumes/Search/ElasticSearch/metricbeatdata01"
mkdir -p "$ROOT/docker/volumes/Search/ElasticSearch/filebeatdata01"
mkdir -p "$ROOT/docker/volumes/Search/ElasticSearch/logstashdata01"

mkdir -p "$ROOT/docker/volumes/Security/Vault/data"

mkdir -p "$ROOT/docker/volumes/SourceControl/Gitea/data"
mkdir -p "$ROOT/docker/volumes/SourceControl/Gitea/runner"

mkdir -p "$ROOT/docker/volumes/Visualization/Grafana/storage"

mkdir -p "$ROOT/docker/volumes/WebServers/Nginx/www"
mkdir -p "$ROOT/docker/volumes/WebServers/Nginx/Nginx"
mkdir -p "$ROOT/docker/volumes/WebServers/Nginx-UI"
mkdir -p "$ROOT/docker/volumes/WebServers/Apache"
