# grafana/otel-lgtm
The whole Grafana observability stack in one container: OpenTelemetry Collector, Prometheus, Tempo, Loki,
Pyroscope and Grafana with the data sources and dashboards already connected.<br>
Grafana: http://localhost:3006 (anonymous admin - local use only)<br>
OTLP: `http://localhost:24317` (gRPC) / `http://localhost:24318` (HTTP) - from other containers `otel-lgtm:4317` / `:4318`<br>
<br>
Quickest way to see an app's traces, metrics and logs together:
```
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:24318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_SERVICE_NAME=orders-api
```
All data is kept in the `data` volume. The separate OpenTelemetry / Prometheus / Grafana stacks remain the
configurable, production-like setup; use one or the other for a given app.

https://github.com/grafana/docker-otel-lgtm
