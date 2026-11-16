# Google Cloud Pub/Sub emulator
Google's Pub/Sub emulator from the `google-cloud-cli` emulators image.

Endpoint: `localhost:8095` (gRPC and REST; from containers on GroupNetwork: `pubsub-emulator:8085`)<br>
Project ID: `local-project` (`PUBSUB_PROJECT_ID`; clients must use the same one)

State is in memory: topics, subscriptions and messages are gone after a restart. Create them at app start-up or in
a test fixture.

## .NET
Set `PUBSUB_EMULATOR_HOST=localhost:8095`; the client libraries then connect to the emulator without credentials.
```csharp
var publisher = await new PublisherServiceApiClientBuilder
{
    EmulatorDetection = EmulatorDetection.EmulatorOrProduction
}.BuildAsync();
var topic = TopicName.FromProjectTopic("local-project", "orders");
await publisher.CreateTopicAsync(topic);
await publisher.PublishAsync(topic, new[] { new PubsubMessage { Data = ByteString.CopyFromUtf8("hello") } });
```
The same `EmulatorDetection` property exists on `SubscriberServiceApiClientBuilder`, `PublisherClientBuilder` and
`SubscriberClientBuilder`.

## Notes
- 8085, the emulator's default port, is used by Gaia (IaC/Terraform), hence 8095 on the host.
- Docs: <https://cloud.google.com/pubsub/docs/emulator>
