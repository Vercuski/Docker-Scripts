# k6
Grafana k6 load and performance testing: tests are JavaScript files with stages, checks and pass/fail thresholds.<br>
One-shot runner: `docker compose up` runs `scripts/<K6_SCRIPT>` (default `smoke.js`) and exits.<br>
Live web dashboard while a test runs: http://localhost:5665<br>

`smoke.js` ramps to 5 virtual users for ~35 s against the **WireMock** stack's sample stub (`http://wiremock:8080`);
start `Testing/WireMock` first, or set `K6_TARGET_URL` (e.g. `http://host.docker.internal:5000/health` for an
app running on your machine, or any GroupNetwork alias). Thresholds: < 1 % failed requests, p95 < 500 ms.

```sh
docker compose up                                         # run K6_SCRIPT, print the summary, exit
docker compose run --rm --service-ports k6 orders.js      # run another file from ./scripts
```
An HTML report is saved as `<script>-report.html` in the `Testing/K6/results` volume folder (k6 skips it for runs
shorter than ~30 s).

Metrics to Prometheus/Grafana: set `K6_EXTRA_OUTPUT=opentelemetry` with the **OpenTelemetry** stack running; k6
sends OTLP to `otel-collector:4317` and the collector exposes the metrics to Prometheus.
(k6's `experimental-prometheus-rw` output still works but is deprecated and goes away in k6 v3.)

https://grafana.com/docs/k6/latest/
