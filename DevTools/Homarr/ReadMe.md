# Homarr
Dashboard / start page edited entirely in the UI: boards with app tiles, widgets (clock, weather, calendar,
bookmarks, iframe, RSS, system/health) and integrations (Docker container status and start/stop, media and
download apps, DNS blockers, Home Assistant...).<br>
UI: http://localhost:7575 (`admin` / `Password123`)<br>

Standalone: SQLite plus a built-in Redis, both under the `appdata` folder. The Docker socket is mounted
**read-only** for the container list (*Manage > Tools > Docker*). Homarr has no environment switch to skip its
onboarding wizard, so on an empty database `homarr-init` uses the Homarr CLI to create the admin, renames the
admin group to `admins` and marks onboarding finished; later runs do nothing.

`HOMARR_SECRET_ENCRYPTION_KEY` (64 hex characters) encrypts integration secrets - keep it together with the data
folder, or the stored secrets can't be read. Make your own with `openssl rand -hex 32` before adding integrations.

Tiles for other stacks: from the browser use `http://localhost:<port>`; for "ping"/status checks Homarr itself
can use the GroupNetwork aliases (e.g. `http://grafana:3000`). For a dashboard kept as YAML in git instead,
see **DevTools/Homepage**.

CLI: `docker exec homarr homarr --help` (reset passwords, list users, recreate the admin).

https://homarr.dev/docs/
