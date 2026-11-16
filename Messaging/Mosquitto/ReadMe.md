# Eclipse Mosquitto (MQTT)
MQTT 3.1.1 / 5 broker.<br>
MQTT: `localhost:1883` (from other containers: `mosquitto:1883`) - user `mqtt` / `Password123`<br>
WebSockets: `ws://localhost:9002` (for browser clients)<br>
<br>
Anonymous clients are refused. The password file is regenerated from `MOSQUITTO_USER` / `MOSQUITTO_PASSWORD` every
time the container starts; for more users, extend the entrypoint in `docker-compose.yml` with more
`mosquitto_passwd -b` lines. Broker settings are in `mosquitto.conf`.

```csharp
// MQTTnet
var client = new MqttClientFactory().CreateMqttClient();
await client.ConnectAsync(new MqttClientOptionsBuilder()
    .WithTcpServer("localhost", 1883).WithCredentials("mqtt", "Password123").Build());
```

https://mosquitto.org/documentation/
