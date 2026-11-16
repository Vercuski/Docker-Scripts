# Apache Artemis (formerly ActiveMQ Artemis)
Message broker speaking Core, OpenWire, AMQP 1.0, STOMP and MQTT. Good fit for MassTransit
(`MassTransit.ActiveMQ` or the AMQP transport) and NServiceBus.<br>
Console: http://localhost:8161/console (`artemis` / `Password123`)<br>
All protocols: `tcp://localhost:61616` · AMQP 1.0: `amqp://localhost:5675` · STOMP: `localhost:61613`<br>
From other containers: `artemis:61616` / `artemis:5672` / `artemis:61613`<br>

```csharp
// MassTransit
x.UsingActiveMq((context, cfg) =>
{
    cfg.Host("localhost", 61616, h => { h.Username("artemis"); h.Password("Password123"); });
    cfg.EnableArtemisCompatibility();
    cfg.ConfigureEndpoints(context);
});
```

The broker instance (`etc/broker.xml`, users, journal) is created in the `instance` volume on the first start;
edit `etc/broker.xml` there to change addresses or security. Addresses created on the fly are multicast, so a
message sent before any consumer exists is dropped (MassTransit creates its queues first, so it is unaffected).<br>
`ARTEMIS_MAX_DISK_USAGE=-1` turns off Artemis' "disk over 90% full, block producers" protection, which otherwise
trips easily on a dev machine.

https://artemis.apache.org/components/artemis/documentation/
