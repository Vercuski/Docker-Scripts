https://www.elastic.co/blog/getting-started-with-the-elastic-stack-and-docker-compose<br>

Elasticsearch: https://localhost:9200 (elastic / ELASTIC_PASSWORD)<br>
Kibana: http://localhost:5601<br>
The `es-setup` container exits after creating certificates - that is expected.<br>
Cannot run at the same time as the OpenSearch stack unless ports are changed (OpenSearch uses 9201/5602 by default).<br>

To solve the memory issue<br>
`wsl -d docker-desktop`<br>
`sysctl -w vm.max_map_count=262144`
