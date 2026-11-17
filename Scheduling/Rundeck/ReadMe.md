# Rundeck
Job scheduler and runbook automation: run commands, scripts and multi-step workflows on nodes, on cron schedules
or on demand, with a web UI, access control and an API.<br>
UI + API: http://localhost:4440 (admin / Password123)<br>

Requires the **PostgreSQL** stack (`rundeck-db-init` creates the `rundeck` role and database). Jobs, projects,
keys and schedules are stored there; execution output logs are in the `logs` volume. The admin password and a
static API token for it are written from `.env` on every start (the image's default `admin/admin` is replaced).

API (version 60 in Rundeck 6.3):
```sh
curl -H "X-Rundeck-Auth-Token: local-dev-rundeck-api-token" -H "Accept: application/json" http://localhost:4440/api/60/projects
```
Jobs run on the Rundeck container itself by default (the `localhost` node); add SSH or WinRM nodes per project.

https://docs.rundeck.com/docs/
