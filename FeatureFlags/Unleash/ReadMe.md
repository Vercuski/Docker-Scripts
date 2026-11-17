# Unleash
Open-source feature flag platform: release / experiment / kill-switch flags, gradual rollout and targeting strategies,
variants, per-environment state (development, production) and an audit log.<br>
UI + APIs: http://localhost:4242 (`admin` / `Password123`; from other stacks `http://unleash:4242`)<br>

Requires the **PostgreSQL** stack (`unleash-db-init` creates the `unleash` role and database). The admin password and
the API tokens below are created when the database is first initialised; afterwards manage them in the UI.

| Token (header `Authorization`) | Use |
|---|---|
| `default:development.local-dev-unleash-client-token` | Backend SDKs (`Unleash.Client`), environment *development* |
| `default:development.local-dev-unleash-frontend-token` | Frontend API / browser SDKs (`/api/frontend`) |
| `*:*.local-dev-unleash-admin-token` | Admin API (scripts, Terraform provider) |

```csharp
// NuGet: Unleash.Client
var unleash = new DefaultUnleash(new UnleashSettings {
    AppName = "my-api",
    UnleashApi = new Uri("http://localhost:4242/api/"),
    CustomHttpHeaders = new() { ["Authorization"] = "default:development.local-dev-unleash-client-token" }
});
if (unleash.IsEnabled("new-checkout")) { /* ... */ }
```
New flags start **disabled** with no strategy: add a strategy (e.g. *Gradual rollout 100 %*) and enable the
environment. SDKs poll every 15 s by default. Unleash also has an OpenFeature provider for .NET.

https://docs.getunleash.io/
