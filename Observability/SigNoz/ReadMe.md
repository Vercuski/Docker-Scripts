# SigNoz
OpenTelemetry-native APM: service maps, traces, logs, metrics, dashboards, exceptions and alerts in one UI, stored
in ClickHouse.<br>
UI: http://localhost:8122<br>
OTLP: `http://localhost:34317` (gRPC) / `http://localhost:34318` (HTTP) - from other containers
`signoz-collector:4317` / `:4318`<br>

## First start
1. Start **Databases/PostgreSQL** (SigNoz keeps users, dashboards and alerts there; `signoz-db-init` creates the
   `signoz` role and database).
2. `docker compose up -d` - about a minute: keeper → ClickHouse → schema migrator → SigNoz + collector. The first
   start downloads ClickHouse's `histogramQuantile` function from GitHub into the `user_scripts` volume.
3. Open http://localhost:8122 and **create the admin account**. The collector only starts accepting OTLP data
   after this step: it receives its pipeline configuration from SigNoz, which needs an organisation.

## Layout
SigNoz now installs through *Foundry* (`foundryctl`); the Compose files that used to be in the SigNoz repo are
deprecated. This stack was generated with `foundryctl forge` (compose flavor) and adapted: metadata in the
PostgreSQL stack instead of a dedicated Postgres, pinned image versions, GroupNetwork aliases
(`signoz`, `signoz-collector`, `signoz-clickhouse`, `signoz-keeper`) and bind-mounted data. The configs in
`collector/`, `clickhouse/` and `keeper/` are the generated ones with the host names changed.<br>
Needs about 4 GB of RAM for Docker.

https://signoz.io/docs/
