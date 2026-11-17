# Dapr
Distributed application runtime: building blocks behind a sidecar API - state, pub/sub, service invocation, actors,
workflows, jobs, secrets, bindings - with the backing services chosen in component YAML files. First-class .NET SDK.<br>
Sidecar HTTP API: http://localhost:3500 - gRPC: `localhost:50001` - Dashboard: http://localhost:8151<br>

This stack replaces `dapr init` for local work: the control plane runs in Docker and one sidecar serves **an app
you run on your machine** (`dotnet run`, Visual Studio, Rider).

| Service | Role |
|---|---|
| `dapr-placement` (:50005) | Actor placement |
| `dapr-scheduler` (:50006) | Jobs API, actor reminders, workflow timers; embedded etcd in the `scheduler` volume |
| `dapr-dashboard` (:8151) | Web dashboard (reads this stack's components and configuration) |
| `dapr-sidecar` (:3500, :50001) | `daprd` for app id `DAPR_APP_ID` (`my-app`); calls your app at `host.docker.internal:DAPR_APP_PORT` (5000) |

Requires the **Redis** stack: `components/statestore.yaml` (also the actor state store) and `components/pubsub.yaml`
use `redis:6379`, DB 4. The password is not in the YAML: the `envsecrets` component reads `REDIS_PASSWORD` from the
sidecar's environment (`DAPR_REDIS_PASSWORD` in `.env`). `config/config.yaml` sends traces to the **OpenTelemetry**
stack (`otel-collector:4317`); without it the sidecar just logs export errors.

Your app needs no Dapr settings: the .NET SDK defaults to `http://localhost:3500` / `http://localhost:50001`.
```csharp
// NuGet: Dapr.AspNetCore - app listening on http://0.0.0.0:5000 (or localhost:5000 on Docker Desktop)
builder.Services.AddControllers().AddDapr();
app.UseCloudEvents();
app.MapSubscribeHandler();
app.MapPost("/orders", [Topic("pubsub", "orders")] (Order o) => Results.Ok());

// elsewhere
await daprClient.SaveStateAsync("statestore", "order-1", order);
await daprClient.PublishEventAsync("pubsub", "orders", order);
```
```sh
curl -X POST http://localhost:3500/v1.0/state/statestore -H "Content-Type: application/json" -d '[{"key":"k","value":42}]'
curl http://localhost:3500/v1.0/state/statestore/k
curl http://localhost:3500/v1.0/metadata          # loaded components, subscriptions, placement status
```
The sidecar starts before your app and waits for port `DAPR_APP_PORT`; start/stop your app freely. If your app listens
on `localhost` only, Docker Desktop still reaches it; on native Linux bind it to `0.0.0.0`.

**More apps:** copy the `dapr-sidecar` service with another name, app id, app port, IP and host ports (e.g. 3501/50002),
and point that app at them with `DAPR_HTTP_ENDPOINT` / `DAPR_GRPC_ENDPOINT`. Containerised apps on GroupNetwork can use
their own `daprd` with `--placement-host-address dapr-placement:50005 --scheduler-host-address dapr-scheduler:50006`.

Components go in `components/` (restart `dapr-sidecar` after changes). Other stacks fit directly: RabbitMQ / Kafka
pub/sub, PostgreSQL / SQL Server state, Consul name resolution, Vault / OpenBao secrets.

https://docs.dapr.io/
