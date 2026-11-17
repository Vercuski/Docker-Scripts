# Traefik
Reverse proxy that configures itself from Docker labels.<br>
HTTP entrypoint: http://localhost:8126 (from other containers: `http://traefik:80`)<br>
Dashboard: http://localhost:8127/dashboard/ (also `/ping` and `/metrics` for Prometheus)<br>

Two providers are enabled:
- **Docker labels**: any container on `GroupNetwork` with `traefik.enable=true` is routed. Add to its compose service:
  ```yaml
  labels:
    - traefik.enable=true
    - traefik.http.routers.myapi.rule=Host(`myapi.localhost`)
    - traefik.http.services.myapi.loadbalancer.server.port=8080   # container-side port
  ```
  then browse http://myapi.localhost:8126 (`*.localhost` resolves to 127.0.0.1 in browsers and curl).
- **Files**: `dynamic/*.yml` is watched and reloaded on change. `dynamic/webservers.yml` round-robins
  http://localhost:8126/web/ over the Nginx and Apache stacks (like HAProxy), with health checks. If an edit isn't picked up
  (file events don't always cross Windows bind mounts), run `docker compose restart traefik`.

The Docker socket is mounted read-only so Traefik can watch containers; the dashboard runs in insecure
(unauthenticated) mode, which is fine for local development only.

https://doc.traefik.io/traefik/
