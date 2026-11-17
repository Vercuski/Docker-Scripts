# flagd
The OpenFeature project's reference flag daemon: flags are **defined as code** in `flags/flags.json` (JSON Logic
targeting, fractional rollouts, typed variants) and evaluated by any OpenFeature SDK. No UI, no database.<br>
Evaluation API (gRPC + Connect): `localhost:8013` - OFREP (HTTP): http://localhost:8016 - health/metrics: http://localhost:8014<br>
From other stacks: `flagd:8013` / `http://flagd:8016`<br>

Edit `flags/flags.json` and flagd reloads it. If a change made on Windows isn't picked up (file events don't always
cross into Docker Desktop's VM), run `docker compose restart flagd`.

Sample flags: `new-checkout` (on for emails ending in `@example.com`), `header-color` (25/50/25 % split by
`targetingKey`), `max-items` (number).

```csharp
// NuGet: OpenFeature + OpenFeature.Contrib.Providers.Flagd
await Api.Instance.SetProviderAsync(new FlagdProvider(new Uri("http://localhost:8013")));
var client = Api.Instance.GetClient();
var ctx = EvaluationContext.Builder().SetTargetingKey(userId).Set("email", email).Build();
bool on = await client.GetBooleanValueAsync("new-checkout", false, ctx);
```
```sh
# OFREP over plain HTTP
curl -X POST http://localhost:8016/ofrep/v1/evaluate/flags/new-checkout \
  -H "Content-Type: application/json" -d '{"context":{"targetingKey":"u1","email":"scott@example.com"}}'
```
Prometheus can scrape `flagd:8014/metrics` (evaluation counts and latency). Writing your code against OpenFeature
keeps the provider swappable (Unleash, Flagsmith, GrowthBook and others have OpenFeature providers too).

https://flagd.dev/
