# Azure Event Hubs emulator
Microsoft's local Event Hubs emulator, speaking AMQP (Azure SDK) and the Kafka protocol.
Requires the Azurite stack (`CloudEmulators/Azurite`): the emulator keeps checkpoints and metadata in Azure Storage.

Event hubs and consumer groups are declared in `Config.json` (the emulator has no management API). The default is
event hub `eh1` with 2 partitions and consumer group `cg1`. Edit it, then `docker compose restart`.

Health: http://localhost:5301/health

## Azure SDK (AMQP)
Connection string from the host (note the port):<br>
`Endpoint=sb://localhost:5674;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;`

From a container on GroupNetwork:<br>
`Endpoint=sb://eventhubs-emulator;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;`

```csharp
await using var producer = new EventHubProducerClient(connectionString, "eh1");
using var batch = await producer.CreateBatchAsync();
batch.TryAdd(new EventData("hello"));
await producer.SendAsync(batch);
```

## Kafka protocol
Bootstrap server `localhost:9094`, SASL PLAIN over plaintext. The username is `$ConnectionString` and the password
is a connection string **whose endpoint names the Kafka port**: the emulator advertises that host and port back to
clients. With the AMQP port (5674) in it, clients are sent to the AMQP listener and fail.

```
bootstrap.servers = localhost:9094
security.protocol = SASL_PLAINTEXT
sasl.mechanism    = PLAIN
sasl.username     = $ConnectionString
sasl.password     = Endpoint=sb://localhost:9094;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;
```
The topic is the event hub name (`eh1`) and the consumer group a configured one (`cg1`). Events sent over AMQP and
Kafka land in the same hub.

## Notes
- Ports are shifted from the defaults because RabbitMQ (5672), the Service Bus emulator (5673, 5300) and the Kafka stack (9092) already use them.
- Docs: <https://learn.microsoft.com/azure/event-hubs/overview-emulator>
