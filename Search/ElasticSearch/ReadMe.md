https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose<br>

Elasticsearch: https://localhost:9200 (elastic / ELASTIC_PASSWORD)<br>
Kibana: http://localhost:5601<br>
The `es-setup` container exits after creating certificates - that is expected.<br>
Cannot run at the same time as the OpenSearch stack unless ports are changed (OpenSearch uses 9201/5602 by default).<br>

Ingest test data: drop `*.log` files into `./filebeat_ingest_data/` (Filebeat) or append lines to files in
`./logstash_ingest_data/` (Logstash, index `logstash-YYYY.MM.dd`). Filebeat also ships every container's logs
(index `filebeat-<version>`); Metricbeat monitors Elasticsearch, Kibana, Logstash and Docker.

## Upgrading from 8.x
The stack runs Elastic **9.5.6**. Elasticsearch 9 opens data written by 8.19 only, so a data folder from the
earlier 8.7.1 pin won't start. Either:
- start fresh: stop the stack and empty the `esdata01` and `kibanadata` folders under
  `<ROOT_VOLUME_DIR>/docker/volumes/Search/ElasticSearch/` (keep `certs`), or
- keep the data: run once with `STACK_VERSION=8.19.25`, wait for Kibana to come up, then switch back to 9.5.6.

Logstash 9 refuses to run as root, so it runs as `1000:0`; on Linux, `CreateVolumes.sh` gives it the
`logstashdata01` folder.

To solve the memory issue<br>
`wsl -d docker-desktop`<br>
`sysctl -w vm.max_map_count=262144`
