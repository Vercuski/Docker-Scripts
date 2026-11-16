# Prometheus
Prometheus: http://localhost:9090<br>
Alertmanager: http://localhost:9093<br>
Node exporter: http://localhost:9100/metrics<br>
<br>
Configuration lives in this folder (`prometheus.yml`, `alertmanager.yml`).<br>
Reload after editing: `curl -X POST http://localhost:9090/-/reload`<br>
<br>
Add Prometheus as a Grafana data source with URL `http://prometheus:9090`.<br>
<br>
https://mxulises.medium.com/simple-prometheus-setup-on-docker-compose-f702d5f98579
