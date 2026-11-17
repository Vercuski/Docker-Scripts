# Plane
Open-source project tracking (Community Edition): work items, cycles (sprints), modules, pages (wiki), views,
analytics, intake and a REST API - a self-hosted alternative to Jira or Linear.<br>
UI: http://localhost:8156 (`admin@example.com` / `Password123`; first login asks you to create a workspace)<br>
Instance admin ("god mode"): http://localhost:8156/god-mode/ - public boards: http://localhost:8156/spaces/<br>

Requires the **PostgreSQL** stack (`plane-db-init` creates the `plane` role and database) and the **Redis** stack
(DB 6); email goes to the **Mailpit** stack. The stack brings the rest:

| Container | Role |
|---|---|
| `plane-proxy` | Caddy front door on 8156; routes come from `config/Caddyfile` (same paths as Plane's own proxy, pointed at the `plane-*` aliases) |
| `plane-web`, `plane-space`, `plane-admin` | App UI, public spaces, god-mode UI |
| `plane-live` | Real-time collaboration for pages |
| `plane-api`, `plane-worker`, `plane-beat-worker` | Django API, Celery worker and scheduler |
| `plane-migrator` | One-shot database migrations (runs before the API on every start) |
| `plane-mq` | RabbitMQ 3.13 as the Celery broker - RabbitMQ 4.x (the Messaging/RabbitMQ stack) refuses Celery's transient control queues |
| `plane-minio` | RustFS S3 store for attachments (bucket `uploads`, created by the API); browsers reach it through the proxy at `/uploads/` |
| `plane-init` | Creates the instance admin and marks setup complete, so the setup wizard is skipped |

API: create a token under *Profile settings > Personal access tokens*, then
```sh
curl -H "X-API-Key: <token>" http://localhost:8156/api/v1/workspaces/<slug>/projects/
```
Webhooks (*Workspace settings > Webhooks*) may call other GroupNetwork stacks (`WEBHOOK_ALLOWED_IPS` = 172.20.0.0/16).
Email (invites, magic links, notifications) goes to the **Mailpit** stack; the SMTP settings are seeded into the
instance on first start and edited afterwards in god mode > Email.

https://docs.plane.so/
