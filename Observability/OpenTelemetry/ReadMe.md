# OpenTelemetry Collector + Tempo + Loki
One OTLP endpoint for all your apps; the collector fans telemetry out to the Grafana stack:

| Signal | Path | View in |
|---|---|---|
| Traces | collector -> Tempo | Grafana (Tempo data source) |
| Logs | collector -> Loki (native OTLP) | Grafana (Loki data source) |
| Metrics | collector -> Prometheus exporter :8889 <- scraped by Prometheus | Grafana (Prometheus data source) |
| Span metrics / service graph | Tempo metrics-generator -> Prometheus remote write | Grafana (Tempo service graph) |

Start order: `Databases/Prometheus`, `Visualization/Grafana`, then this stack.

Point your apps at the collector:<br>
```
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317       # from containers on GroupNetwork: http://otel-collector:4317
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_SERVICE_NAME=MyApi
```

Endpoints: Tempo API http://localhost:3200 · Loki API http://localhost:3100 · collector health http://localhost:13133

Config files in this folder: `otel-collector-config.yaml`, `tempo.yaml`, `loki.yaml`. Retention: Loki 7 days
(`retention_period`), Tempo 14 days (default `block_retention`). Want the Aspire Dashboard too? See the commented
`otlp/aspire` exporter in the collector config.

Linux hosts: Tempo and Loki run as UID 10001 - `sudo chown -R 10001:10001` the two volume folders if they fail to write.
