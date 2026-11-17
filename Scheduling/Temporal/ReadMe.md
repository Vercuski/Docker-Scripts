# Temporal
Durable execution engine: workflows written as ordinary code survive crashes, restarts and deploys (retries,
timers, signals, schedules and full history are handled by the server).<br>
Frontend (gRPC): `localhost:7233` (from other containers: `temporal:7233`)<br>
Web UI: http://localhost:8135<br>

Requires the **PostgreSQL** stack. On every `docker compose up`, `temporal-db-init` creates the `temporal` role and
the `temporal` / `temporal_visibility` databases if missing, `temporal-schema` creates or upgrades their schemas
(safe to rerun after bumping `TEMPORAL_VERSION`), and `temporal-namespace-init` creates the `default` namespace.

.NET: add the `Temporalio` NuGet package and connect with
```csharp
var client = await TemporalClient.ConnectAsync(new("localhost:7233") { Namespace = "default" });
```
then run a worker (`TemporalWorker`) for your task queue. Recurring work uses Temporal Schedules (UI, SDK, or the
`temporal` CLI, which ships in the admin-tools image):
```sh
docker run --rm --network GroupNetwork -e TEMPORAL_ADDRESS=temporal:7233 temporalio/admin-tools:1.32.2 \
  temporal schedule create --schedule-id nightly --cron "0 2 * * *" --workflow-id nightly --type NightlyReport --task-queue reports
```
Dynamic configuration: `dynamicconfig/development-sql.yaml` (re-read by the server every few seconds).

https://docs.temporal.io/develop/dotnet
