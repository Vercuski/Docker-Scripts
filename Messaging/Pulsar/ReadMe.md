# Apache Pulsar (standalone)
Distributed pub/sub and queueing with multi-tenancy, geo-replication and tiered storage; here as a single-container
standalone cluster for development.<br>
Service URL: `pulsar://localhost:6650` (from other containers: `pulsar://pulsar:6650`)<br>
Admin REST API: http://localhost:8117 (e.g. `/admin/v2/persistent/public/default`)<br>

```csharp
// DotPulsar
await using var client = PulsarClient.Builder().ServiceUrl(new Uri("pulsar://localhost:6650")).Build();
await using var producer = client.NewProducer(Schema.String).Topic("persistent://public/default/orders").Create();
await producer.Send("order-1");
```
CLI: `docker exec -it pulsar bin/pulsar-admin topics list public/default`<br>
Functions worker and stream storage are disabled to keep memory down. No web UI is included: Pulsar Manager has
not been released since 2023.

https://pulsar.apache.org/docs/
