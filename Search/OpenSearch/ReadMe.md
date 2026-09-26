OpenSearch: https://localhost:9201 (admin / OPENSEARCH_INITIAL_ADMIN_PASSWORD from .env)<br>
Dashboards: http://localhost:5602<br>
The admin password is only applied when the data folders are empty.<br>

To solve the memory issue<br>
`wsl -d docker-desktop`<br>
`sysctl -w vm.max_map_count=262144`
