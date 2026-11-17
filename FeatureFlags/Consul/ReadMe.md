# Consul
HashiCorp Consul as a single server: **key/value configuration store** (with blocking queries, so apps reload on
change), service catalog with health checks, and DNS service discovery.<br>
UI + HTTP API: http://localhost:8500 - DNS: `localhost:8600` (tcp/udp) - from other stacks `http://consul:8500`<br>

Runs as a real (non-dev) server, so KV data and registrations persist in the `data` volume. ACLs are off (local use).
`consul-init` imports `kv/seed.json` when `config/` is empty:

| Key | Value |
|---|---|
| `config/my-api/appsettings.json` | JSON settings block (`FeatureManagement`, `Checkout`) |
| `config/my-api/ConnectionStrings/Orders` | SQL Server stack connection string |
| `config/shared/Logging/LogLevel/Default` | `Information` |

Export your own keys back to a seed file: `docker exec consul consul kv export config/ > kv/seed.json`.

ASP.NET Core configuration provider:
```csharp
// NuGet: Winton.Extensions.Configuration.Consul
builder.Configuration.AddConsul("config/my-api/appsettings.json", o =>
{
    o.ConsulConfigurationOptions = c => c.Address = new Uri("http://localhost:8500");
    o.ReloadOnChange = true;   // IOptionsMonitor<T> / IFeatureManager see edits made in the UI
    o.Optional = true;
});
```
```sh
curl "http://localhost:8500/v1/kv/config/my-api/appsettings.json?raw"
curl -X PUT --data "Warning" http://localhost:8500/v1/kv/config/shared/Logging/LogLevel/Default
```
Service discovery: register services through the API or an agent; they resolve as `<name>.service.consul` on port 8600.

Licensing: Consul is under the Business Source License since 1.17, which allows this kind of internal use.

https://developer.hashicorp.com/consul/docs
