# Envoy
L4/L7 proxy (the data plane behind Istio and most service meshes) with a static configuration.<br>
Listener: http://localhost:8130 (round-robins over the Nginx and Apache stacks, like HAProxy)<br>
Admin: http://localhost:9902 (`/stats`, `/clusters`, `/config_dump`, `/stats/prometheus`)<br>

Edit `envoy.yaml`, then `docker compose restart envoy`. The `webservers` cluster uses `STRICT_DNS` with Docker's
DNS and an active HTTP health check every 10 s, so a stopped backend is removed after two failed checks.

https://www.envoyproxy.io/docs/envoy/latest/
