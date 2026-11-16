# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of independent Docker Compose stacks for a local development environment (mostly aimed at .NET work). There is no build or test suite; each stack is `<Category>/<Tool>/` containing `docker-compose.yml`, `.env`, `ReadMe.md`, and any mounted config files (e.g. `prometheus.yml`, `haproxy.cfg`, `vault.hcl`). `REVIEW.md` records past audit findings, the host-port map, and open "flagged but not changed" items.

## Commands

```sh
./CreateNetwork.sh    # or CreateNetwork.bat — creates external GroupNetwork (172.20.0.0/16), required by every stack
./CreateVolumes.sh    # or CreateVolumes.bat — creates the host folders behind bind-mounted volumes
cd <Category>/<Tool> && docker compose up -d
docker compose config # validate a stack and show fully resolved values (the main "test")
```

`ROOT_VOLUME_DIR` is the only host-specific value. It is **not** set in any `.env`; `CreateVolumes.bat` (default `D:`, saved with `setx`) or `CreateVolumes.sh` (default `$HOME`, saved to the shell rc file) sets it once per machine. Both accept an optional root argument. For ad-hoc validation: `ROOT_VOLUME_DIR=/tmp docker compose config`.

## Conventions that span multiple files

When adding or changing a stack, these must stay consistent across the repo:

- **Shared network**: every service joins the external `GroupNetwork` with a static `ipv4_address` and a network `aliases` entry used as its DNS name by other stacks. IP ranges are grouped by category; the authoritative IP table is in `README.md` — update it when adding services. IPs, host ports, aliases and `container_name`s must be unique across *all* stacks (see the host-port map in `REVIEW.md`).
- **`.env` holds every settable value**, grouped under the headers `Image versions`, `Host ports`, `Network (static IPs)`, `Credentials & settings`, `Tuning`. Compose references them as `${VAR:-default}` where the default is **identical** to the `.env` value, so a stack still works with an empty `.env` (plus `ROOT_VOLUME_DIR` in the environment). Each `.env` keeps a commented `# ROOT_VOLUME_DIR=D:` line for a per-stack override. Internal wiring (container-side ports, service DNS names, cert paths) stays hard-coded in compose.
- **Volumes** are named local volumes bound to `${ROOT_VOLUME_DIR:?run CreateVolumes.bat or CreateVolumes.sh first}/docker/volumes/<Category>/<Tool>/<sub>` (`:?` is intentional — no default). Any new path must be added to **both** `CreateVolumes.sh` (`mkdir -p`) and `CreateVolumes.bat` (`call :mk`), with identical case (Linux is case-sensitive). If the image runs as a fixed non-root UID and doesn't chown its own data dir, add the path to the `own` list in `CreateVolumes.sh`.
- Long-running services use `restart: unless-stopped`; one-shot setup containers use `restart: "no"`. No top-level `version:` key. Pin image major versions where a floating tag would break existing data (e.g. Postgres, InfluxDB).
- Line endings are enforced by `.gitattributes`: `*.sh` and `*.cfg` LF, `*.bat` CRLF.
- Credentials like `Password123` are intentional local-dev defaults.

## Cross-stack dependencies

Stacks talk to each other over `GroupNetwork` by alias, so some require another stack to be running:
- Keycloak and SuperTokens → PostgreSQL stack (their own databases must exist)
- Azure Service Bus emulator, Hangfire → MSSQL stack (`mssqldb`)
- OpenTelemetry Collector → Tempo/Loki (same stack) and Prometheus (`Databases/Prometheus`, which scrapes `otel-collector:8889` and accepts remote-write from Tempo)
- Grafana provisions Prometheus, Tempo, Loki and InfluxDB data sources from `Visualization/Grafana/provisioning/datasources/datasources.yaml`
- HAProxy round-robins to the Nginx and Apache web server stacks

## Verifying changes

Validation used in this repo: run `docker compose config` on every stack, check for duplicate IPs / host ports / aliases / container names across all compose files, confirm every bind path exists in `CreateVolumes`, and confirm `.env` values equal the compose defaults.
