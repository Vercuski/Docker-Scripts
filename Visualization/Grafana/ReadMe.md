http://localhost:3000 (admin / Password123)<br>
Data sources are provisioned from `provisioning/datasources/datasources.yaml`: Prometheus, Tempo, Loki and InfluxDB
(values match the defaults in those stacks' `.env` files - update the file if you change them).<br>
Traces link to logs (Tempo -> Loki) and logs link back to traces via `trace_id`.
