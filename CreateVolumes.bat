@echo off
REM Creates the host folders behind the bind-mounted volumes and sets ROOT_VOLUME_DIR for docker compose.
REM
REM Usage: CreateVolumes.bat [root]      e.g.  CreateVolumes.bat D:   or   CreateVolumes.bat C:\dev
REM   root defaults to %ROOT_VOLUME_DIR% if already set, otherwise D:
REM   Set SKIP_PERSIST=1 to skip saving ROOT_VOLUME_DIR as a user environment variable.
setlocal

if not "%~1"=="" (
    set "ROOT=%~1"
) else if defined ROOT_VOLUME_DIR (
    set "ROOT=%ROOT_VOLUME_DIR%"
) else (
    set "ROOT=D:"
)
REM Drop a trailing slash, use backslashes for mkdir and forward slashes for compose
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
if "%ROOT:~-1%"=="/" set "ROOT=%ROOT:~0,-1%"
set "ROOT=%ROOT:/=\%"
set "ROOT_FWD=%ROOT:\=/%"
set "V=%ROOT%\docker\volumes"
echo Creating volume folders under %V%
call :mk Analytics\ApacheFlink\checkpoints
call :mk Analytics\ApacheFlink\savepoints
call :mk Analytics\ApacheFlink\jobs
call :mk Analytics\ApacheSpark\data
call :mk Analytics\ApacheSpark\apps
call :mk Analytics\ApacheSpark\logs
call :mk Analytics\JupyterLab\work
call :mk Analytics\Seq\data

call :mk Authentication\Authelia\data
call :mk Authentication\Authentik\data
call :mk Authentication\Authentik\certs
call :mk Authentication\Authentik\templates
call :mk Authentication\Zitadel\bootstrap

call :mk CloudEmulators\Azurite\data
call :mk CloudEmulators\AzureCosmosDb\data
call :mk CloudEmulators\Floci\data
call :mk CloudEmulators\GcpFirestore\data
call :mk CloudEmulators\LocalStack\data
call :mk CloudEmulators\LowkeyVault\data

call :mk CodeAnalysis\SonarQube\data
call :mk CodeAnalysis\SonarQube\extensions
call :mk CodeAnalysis\SonarQube\logs
call :mk CodeAnalysis\DependencyTrack\data
call :mk CodeAnalysis\DefectDojo\media
call :mk CodeAnalysis\DefectDojo\valkey
call :mk CodeAnalysis\Trivy\cache

call :mk Containerization\DockerRegistry\data
call :mk Containerization\Harbor\core
call :mk Containerization\Harbor\registry-config
call :mk Containerization\Harbor\registry
call :mk Containerization\Harbor\job_logs
call :mk Containerization\Harbor\trivy
call :mk Containerization\Harbor\redis
call :mk Containerization\Zot\data

call :mk Databases\ApacheCassandra
call :mk Databases\ClickHouse\data
call :mk Databases\ClickHouse\logs
call :mk Databases\CloudBeaver\workspace
call :mk Databases\CockroachDB\data
call :mk Databases\Couchbase\data
call :mk Databases\CouchDB\data
call :mk Databases\Garnet\data
call :mk Databases\InfluxDb\config
call :mk Databases\InfluxDb\data
call :mk Databases\KurrentDB\data
call :mk Databases\KurrentDB\logs
call :mk Databases\MariaDB\Backup
call :mk Databases\MariaDB\Data
call :mk Databases\Milvus\milvus
call :mk Databases\Milvus\etcd
call :mk Databases\Milvus\minio
call :mk Databases\MongoDb\data
call :mk Databases\MSSQL\data
call :mk Databases\MSSQL\log
call :mk Databases\MSSQL\secrets
call :mk Databases\MySQL
call :mk Databases\Neo4J\data
call :mk Databases\Neo4J\logs
call :mk Databases\Neo4J\import
call :mk Databases\Neo4J\plugins
call :mk Databases\Oracle\Data
call :mk Databases\Oracle\Backup
call :mk Databases\PostgreSQL\Data
call :mk Databases\PostgreSQL\pgadmin4data
call :mk Databases\Qdrant\storage
call :mk Databases\RavenDB\data
call :mk Databases\Redis\cache
call :mk Databases\ScyllaDB\data
call :mk Databases\TimescaleDB\data
call :mk Databases\Valkey\data

call :mk Documentation\BookStack\config
call :mk Documentation\Mediawiki\html
call :mk Documentation\Outline\data
call :mk Documentation\Structurizr\workspace
call :mk Documentation\WikiJs\data

call :mk Email\Mailpit\data
call :mk Email\Smtp4dev\data

call :mk IaC\Atlantis\data
call :mk IaC\Semaphore\data

call :mk Messaging\Artemis\instance
call :mk Messaging\Kafka\Kafka\data
call :mk Messaging\Mosquitto\data
call :mk Messaging\NATS\data
call :mk Messaging\Pulsar\data
call :mk Messaging\RabbitMQ\data
call :mk Messaging\RabbitMQ\log
call :mk Messaging\Redpanda\data

call :mk Observability\Jaeger\badger
call :mk Observability\OpenTelemetry\tempo
call :mk Observability\OpenTelemetry\loki
call :mk Observability\Prometheus\prometheus_data
call :mk Observability\OtelLgtm\data
call :mk Observability\Prometheus\alertmanager
call :mk Observability\Pyroscope\data
call :mk Observability\SigNoz\clickhouse
call :mk Observability\SigNoz\keeper
call :mk Observability\SigNoz\user_scripts
call :mk Observability\UptimeKuma\data

call :mk Orchestration\K3s\server
call :mk Orchestration\K3s\kubeconfig
call :mk Orchestration\Rancher\data
call :mk Orchestration\Portainer\data

call :mk Packages\BaGetter\data
call :mk Packages\Nexus\data
call :mk Packages\ProGet\packages
call :mk Packages\ProGet\ssl
call :mk Packages\Verdaccio\storage

call :mk RP-LB\Caddy\config
call :mk RP-LB\Caddy\data
call :mk RP-LB\NginxProxyManager\data
call :mk RP-LB\NginxProxyManager\letsencrypt
call :mk Scheduling\Airflow\logs
call :mk Scheduling\N8n\data
call :mk Scheduling\Rundeck\logs

call :mk Search\OpenSearch\node1
call :mk Search\OpenSearch\node2
call :mk Search\ElasticSearch\certs
call :mk Search\ElasticSearch\esdata01
call :mk Search\ElasticSearch\kibanadata
call :mk Search\ElasticSearch\metricbeatdata01
call :mk Search\ElasticSearch\filebeatdata01
call :mk Search\ElasticSearch\logstashdata01
call :mk Search\Meilisearch\data
call :mk Search\Solr\data
call :mk Search\Typesense\data

call :mk Security\OpenBao\data
call :mk Security\StepCa\data
call :mk Security\Vault\data
call :mk Security\Zap\wrk

call :mk SIEM\Graylog\datanode
call :mk SIEM\Graylog\mongodb
call :mk SIEM\Graylog\server
call :mk SIEM\Wazuh\certs
call :mk SIEM\Wazuh\manager\api_configuration
call :mk SIEM\Wazuh\manager\etc
call :mk SIEM\Wazuh\manager\logs
call :mk SIEM\Wazuh\manager\queue
call :mk SIEM\Wazuh\manager\var_multigroups
call :mk SIEM\Wazuh\manager\integrations
call :mk SIEM\Wazuh\manager\active_response
call :mk SIEM\Wazuh\manager\agentless
call :mk SIEM\Wazuh\manager\wodles
call :mk SIEM\Wazuh\manager\filebeat_etc
call :mk SIEM\Wazuh\manager\filebeat_var
call :mk SIEM\Wazuh\indexer\data
call :mk SIEM\Wazuh\dashboard\config
call :mk SIEM\Wazuh\dashboard\custom

call :mk SourceControl\Gitea\data
call :mk SourceControl\Gitea\runner
call :mk SourceControl\Forgejo\data
call :mk SourceControl\Forgejo\runner
call :mk SourceControl\GitLab\config
call :mk SourceControl\GitLab\data
call :mk SourceControl\GitLab\logs
call :mk SourceControl\OneDev\data

call :mk Visualization\Grafana\storage

call :mk WebServers\Nginx\www
call :mk WebServers\Nginx\Nginx
call :mk WebServers\Nginx-UI
call :mk WebServers\Apache

if not "%SKIP_PERSIST%"=="1" (
    setx ROOT_VOLUME_DIR "%ROOT_FWD%" >nul
    echo ROOT_VOLUME_DIR=%ROOT_FWD% saved as a user environment variable - open a new terminal before running docker compose.
)
endlocal
goto :eof

:mk
if not exist "%V%\%~1" mkdir "%V%\%~1"
exit /b
