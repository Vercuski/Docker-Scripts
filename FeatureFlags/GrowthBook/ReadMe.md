# GrowthBook
Open-source feature flags **and** A/B experimentation: flags with targeting and percentage rollouts, experiments
analysed by a Bayesian/frequentist stats engine against your own warehouse (PostgreSQL, SQL Server, ClickHouse, ...).<br>
UI: http://localhost:3011 (`admin@example.com` / `Password123`) - API: http://localhost:3012<br>

Self-contained: GrowthBook only supports MongoDB, so the stack runs its own **MongoDB 8.0** (`growthbook-mongo`)
instead of the Databases/MongoDB stack (`latest` = 9.x there).

On an empty database `growthbook-init` performs GrowthBook's first-time registration (super admin, organisation
`Docker-Scripts`, "My First Project") and creates an SDK connection **Local dev** for the `production` environment.
Its client key is in the init log:
```sh
docker logs growthbook-init      # "SDK connection 'Local dev' client key: sdk-..."
curl http://localhost:3012/api/features/<client key>
```
Later starts leave everything alone (the admin password is not reset; change it in the UI).

```csharp
// NuGet: growthbook-c-sharp
var gb = new GrowthBook.GrowthBook(new Context {
    ApiHost = "http://localhost:3012", ClientKey = "<client key>",
    Attributes = new JObject { ["id"] = userId }
});
await gb.LoadFeatures();
if (gb.IsOn("new-checkout")) { /* ... */ }
```
Experiment analysis needs a data source (Settings > Data Sources), e.g. the PostgreSQL stack at `postgresql:5432`.

https://docs.growthbook.io/
