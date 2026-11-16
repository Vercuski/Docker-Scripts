#!/usr/bin/env bash
# Creates the host folders behind the bind-mounted volumes and sets ROOT_VOLUME_DIR for docker compose.
#
# Usage: ./CreateVolumes.sh [root]
#   root defaults to $ROOT_VOLUME_DIR if already set, otherwise $HOME.
#
# Optional environment switches:
#   SKIP_CHOWN=1    don't change folder ownership (Linux only; see below)
#   SKIP_PERSIST=1  don't write ROOT_VOLUME_DIR to your shell startup file
set -euo pipefail
ROOT="${1:-${ROOT_VOLUME_DIR:-$HOME}}"
ROOT="${ROOT%/}"
echo "Creating volume folders under $ROOT/docker/volumes"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheFlink/checkpoints"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheFlink/savepoints"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheFlink/jobs"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheSpark/data"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheSpark/apps"
mkdir -p "$ROOT/docker/volumes/Analytics/ApacheSpark/logs"
mkdir -p "$ROOT/docker/volumes/Analytics/JupyterLab/work"
mkdir -p "$ROOT/docker/volumes/Analytics/Seq/data"

mkdir -p "$ROOT/docker/volumes/Authentication/Authelia/data"
mkdir -p "$ROOT/docker/volumes/Authentication/Authentik/data"
mkdir -p "$ROOT/docker/volumes/Authentication/Authentik/certs"
mkdir -p "$ROOT/docker/volumes/Authentication/Authentik/templates"
mkdir -p "$ROOT/docker/volumes/Authentication/Zitadel/bootstrap"

mkdir -p "$ROOT/docker/volumes/CloudEmulators/Azurite/data"
mkdir -p "$ROOT/docker/volumes/CloudEmulators/AzureCosmosDb/data"
mkdir -p "$ROOT/docker/volumes/CloudEmulators/Floci/data"
mkdir -p "$ROOT/docker/volumes/CloudEmulators/GcpFirestore/data"
mkdir -p "$ROOT/docker/volumes/CloudEmulators/LocalStack/data"
mkdir -p "$ROOT/docker/volumes/CloudEmulators/LowkeyVault/data"

mkdir -p "$ROOT/docker/volumes/CodeAnalysis/SonarQube/data"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/SonarQube/extensions"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/SonarQube/logs"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/DependencyTrack/data"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/DefectDojo/media"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/DefectDojo/valkey"
mkdir -p "$ROOT/docker/volumes/CodeAnalysis/Trivy/cache"

mkdir -p "$ROOT/docker/volumes/Containerization/DockerRegistry/data"
mkdir -p "$ROOT/docker/volumes/Containerization/Harbor/core"
mkdir -p "$ROOT/docker/volumes/Containerization/Harbor/registry-config"
mkdir -p "$ROOT/docker/volumes/Containerization/Harbor/registry"
mkdir -p "$ROOT/docker/volumes/Containerization/Harbor/job_logs"
mkdir -p "$ROOT/docker/volumes/Containerization/Harbor/trivy"
mkdir -p "$ROOT/docker/volumes/Containerization/Harbor/redis"
mkdir -p "$ROOT/docker/volumes/Containerization/Zot/data"

mkdir -p "$ROOT/docker/volumes/Databases/ApacheCassandra"
mkdir -p "$ROOT/docker/volumes/Databases/ClickHouse/data"
mkdir -p "$ROOT/docker/volumes/Databases/ClickHouse/logs"
mkdir -p "$ROOT/docker/volumes/Databases/CloudBeaver/workspace"
mkdir -p "$ROOT/docker/volumes/Databases/CockroachDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/Couchbase/data"
mkdir -p "$ROOT/docker/volumes/Databases/CouchDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/Garnet/data"
mkdir -p "$ROOT/docker/volumes/Databases/InfluxDb/config"
mkdir -p "$ROOT/docker/volumes/Databases/InfluxDb/data"
mkdir -p "$ROOT/docker/volumes/Databases/KurrentDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/KurrentDB/logs"
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
mkdir -p "$ROOT/docker/volumes/Databases/Qdrant/storage"
mkdir -p "$ROOT/docker/volumes/Databases/RavenDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/Redis/cache"
mkdir -p "$ROOT/docker/volumes/Databases/ScyllaDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/TimescaleDB/data"
mkdir -p "$ROOT/docker/volumes/Databases/Valkey/data"

mkdir -p "$ROOT/docker/volumes/Documentation/Mediawiki/html"

mkdir -p "$ROOT/docker/volumes/Email/Mailpit/data"

mkdir -p "$ROOT/docker/volumes/IaC/Terraform/data"

mkdir -p "$ROOT/docker/volumes/Messaging/Kafka/Kafka/data/"
mkdir -p "$ROOT/docker/volumes/Messaging/RabbitMQ/data"
mkdir -p "$ROOT/docker/volumes/Messaging/RabbitMQ/log"

mkdir -p "$ROOT/docker/volumes/Observability/OpenTelemetry/tempo"
mkdir -p "$ROOT/docker/volumes/Observability/OpenTelemetry/loki"
mkdir -p "$ROOT/docker/volumes/Observability/Prometheus/prometheus_data"
mkdir -p "$ROOT/docker/volumes/Observability/Prometheus/alertmanager"

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

mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/certs"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/api_configuration"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/etc"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/logs"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/queue"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/var_multigroups"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/integrations"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/active_response"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/agentless"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/wodles"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/filebeat_etc"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/manager/filebeat_var"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/indexer/data"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/dashboard/config"
mkdir -p "$ROOT/docker/volumes/SIEM/Wazuh/dashboard/custom"

mkdir -p "$ROOT/docker/volumes/SourceControl/Gitea/data"
mkdir -p "$ROOT/docker/volumes/SourceControl/Gitea/runner"

mkdir -p "$ROOT/docker/volumes/Visualization/Grafana/storage"

mkdir -p "$ROOT/docker/volumes/WebServers/Nginx/www"
mkdir -p "$ROOT/docker/volumes/WebServers/Nginx/Nginx"
mkdir -p "$ROOT/docker/volumes/WebServers/Nginx-UI"
mkdir -p "$ROOT/docker/volumes/WebServers/Apache"

# --- Ownership (Linux only) -------------------------------------------------------------
# Docker Desktop (Windows/macOS) ignores bind-mount ownership. On native Linux, images that
# run as a fixed non-root user can't write to folders owned by you. Images whose entrypoint
# fixes ownership itself (Postgres, MySQL, MariaDB, Mongo, Redis, ClickHouse, Cassandra, Neo4j,
# RabbitMQ, InfluxDB, Gitea, ...) are not listed.
if [ "$(uname -s)" = "Linux" ] && [ "${SKIP_CHOWN:-0}" != "1" ]; then
  SUDO=""
  if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; echo "Setting folder ownership for non-root images (sudo)"; fi
  own() { local ids="$1"; shift; for d in "$@"; do $SUDO chown -R "$ids" "$ROOT/docker/volumes/$d"; done; }

  own 9999:9999   Analytics/ApacheFlink/checkpoints Analytics/ApacheFlink/savepoints Analytics/ApacheFlink/jobs  # flink
  own 185:185     Analytics/ApacheSpark/data Analytics/ApacheSpark/apps Analytics/ApacheSpark/logs  # spark
  own 185:100     Analytics/JupyterLab/work                                                       # jovyan runs as spark's UID
  own 1000:1000   Authentication/Authentik/data Authentication/Authentik/certs Authentication/Authentik/templates  # authentik
  own 1000:0      CodeAnalysis/DependencyTrack/data                                               # dtrack
  own 1001:1337   CodeAnalysis/DefectDojo/media                                                   # defectdojo
  own 1000:1000   CodeAnalysis/SonarQube/data CodeAnalysis/SonarQube/extensions CodeAnalysis/SonarQube/logs
  own 1654:1654   Databases/Garnet/data                                                          # garnet
  own 1001:1001   Databases/KurrentDB/data Databases/KurrentDB/logs                               # kurrent
  own 54321:54321 Databases/Oracle/Data Databases/Oracle/Backup                                   # oracle
  own 5050:5050   Databases/PostgreSQL/pgadmin4data                                               # pgadmin
  own 999:999     Databases/RavenDB/data                                                         # ravendb
  own 998:1000    Databases/ScyllaDB/data                                                        # scylla
  own 1000:1000   Messaging/Kafka/Kafka/data                                                      # apache/kafka appuser
  own 10001:10001 Observability/OpenTelemetry/tempo Observability/OpenTelemetry/loki
  own 65534:65534 Observability/Prometheus/prometheus_data Observability/Prometheus/alertmanager  # nobody
  own 1000:0      Search/ElasticSearch/esdata01 Search/ElasticSearch/kibanadata
  own 1000:1000   Search/OpenSearch/node1 Search/OpenSearch/node2
  own 100:1000    Security/Vault/data                                                             # vault
  own 1000:1000   SIEM/Wazuh/indexer/data SIEM/Wazuh/dashboard/config SIEM/Wazuh/dashboard/custom
  own 472:0       Visualization/Grafana/storage                                                   # grafana
fi

# --- Persist ROOT_VOLUME_DIR --------------------------------------------------------------
# docker compose reads it from the environment (no .env sets it any more).
if [ "${SKIP_PERSIST:-0}" != "1" ]; then
  case "$(basename "${SHELL:-bash}")" in
    zsh)  RC="$HOME/.zshenv" ;;
    bash) RC="$HOME/.bashrc" ;;
    *)    RC="$HOME/.profile" ;;
  esac
  BEGIN="# >>> Docker-Scripts >>>"; END="# <<< Docker-Scripts <<<"
  touch "$RC"
  if grep -qF "$BEGIN" "$RC"; then
    sed -i.bak "/$BEGIN/,/$END/d" "$RC" && rm -f "$RC.bak"
  fi
  printf '%s\nexport ROOT_VOLUME_DIR="%s"\n%s\n' "$BEGIN" "$ROOT" "$END" >> "$RC"
  echo "ROOT_VOLUME_DIR=$ROOT saved to $RC - open a new terminal (or: source $RC)."
fi
