# Mattermost
Open-source team chat (Team Edition): channels, threads, direct messages, file sharing, bots, slash commands and
incoming/outgoing webhooks - a self-hosted target for build, deploy and monitoring notifications.<br>
UI + API: http://localhost:8065 (`admin` / `Password123`, team **docker-scripts**; from other stacks `http://mattermost:8065`)<br>

Requires the **PostgreSQL** stack (`mattermost-db-init` creates the `mattermost` role and database). Email
notifications go to the **Mailpit** stack. On an empty database `mattermost-init` creates the admin - the first user
in Mattermost is the system admin - and the team; later runs only check they exist.

Settings come from `MM_*` environment variables in `docker-compose.yml` (they override `config.json` and show as
read-only in the System Console). Local mode is on, so `mmctl` works inside the container without logging in:
```sh
docker exec mattermost mmctl --local user list
docker exec mattermost mmctl --local webhook create-incoming --channel docker-scripts:town-square --user admin --display-name alerts
```
Alerts: create an incoming webhook (above, or *Integrations > Incoming Webhooks*) and post to it -
Grafana contact point type *Mattermost* or Alertmanager's webhook, URL `http://mattermost:8065/hooks/<id>`:
```sh
curl -H "Content-Type: application/json" http://localhost:8065/hooks/<id> -d '{"text":"Deploy finished"}'
```
Outgoing webhooks / integrations may call addresses on GroupNetwork (`AllowedUntrustedInternalConnections` = 172.20.0.0/16).

https://docs.mattermost.com/
