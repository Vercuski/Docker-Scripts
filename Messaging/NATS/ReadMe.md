# NATS (JetStream)
Lightweight messaging: subjects with pub/sub, request/reply and queue groups, plus JetStream for persistent streams,
durable consumers, key/value and object stores.<br>
Client URL: `nats://nats:Password123@localhost:4222` (from other containers: `nats://nats:4222`)<br>
Monitoring: http://localhost:8222 (`/varz`, `/connz`, `/jsz`)<br>

```csharp
// NATS.Net
await using var nats = new NatsClient(new NatsOpts { Url = "nats://localhost:4222",
    AuthOpts = new NatsAuthOpts { Username = "nats", Password = "Password123" } });
var js = nats.CreateJetStreamContext();
await js.CreateStreamAsync(new StreamConfig("ORDERS", ["orders.*"]));
await js.PublishAsync("orders.created", "order-1");
```
CLI: the `nats` tool (`nats --server nats://nats:Password123@localhost:4222 stream ls`).

https://docs.nats.io/
