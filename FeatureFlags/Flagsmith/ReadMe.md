# Flagsmith
Open-source feature flags and remote config: flags with values, per-environment state, segments (rules on user
traits), identity overrides, scheduled changes and an audit log.<br>
UI + API: http://localhost:8149 (`admin@example.com` / `Password123`; from other stacks `http://flagsmith:8000`)<br>
Django admin: http://localhost:8149/admin/<br>

Requires the **PostgreSQL** stack (`flagsmith-db-init` creates the `flagsmith` role and database).
On an empty database the server's bootstrap creates the admin user, organisation `Docker-Scripts` and project
`Default`. `flagsmith-init` then sets the admin password from `.env` (on every start), adds the **Development** and
**Production** environments once, and prints their environment keys:
```sh
docker logs flagsmith-init     # "Development client-side environment key: ..."
```
Sign-up is disabled (`FLAGSMITH_PREVENT_SIGNUP=true`); invite users from the organisation settings.

```csharp
// NuGet: Flagsmith
var flagsmith = new FlagsmithClient(new FlagsmithConfiguration {
    EnvironmentKey = "<Development environment key>",
    ApiUrl = "http://localhost:8149/api/v1/"
});
var flags = await flagsmith.GetEnvironmentFlags();
if (await flags.IsFeatureEnabled("new_checkout")) { var colour = await flags.GetFeatureValue("new_checkout"); }
```
```sh
curl -H "X-Environment-Key: <key>" http://localhost:8149/api/v1/flags/
```
For local evaluation in the SDK, create a **server-side** key (Environment settings > SDK keys). There's also an
OpenFeature provider for .NET.

https://docs.flagsmith.com/
