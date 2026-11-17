# Node-RED
Low-code, flow-based automation in the browser: wire HTTP endpoints, webhooks, timers, MQTT, Kafka, RabbitMQ,
databases and scripts (JavaScript function nodes) together, with thousands of community nodes.<br>
Editor: http://localhost:1880 (`admin` / `Password123`; from other stacks `http://node-red:1880`)<br>

`settings.js` (mounted read-only) takes the editor login and the credential secret from `.env`; the password is
bcrypt-hashed at start, so changing `NODERED_ADMIN_PASSWORD` and restarting is enough. Flows (`flows.json`),
encrypted credentials and nodes installed via *Manage palette* live in the `data` volume.

HTTP-in endpoints of your flows are served on the same port without login, e.g. a flow with
`[http in GET /hello] -> [function] -> [http response]` answers on http://localhost:1880/hello.

Useful connections to other stacks (by alias on GroupNetwork): `mosquitto:1883` (MQTT), `kafka:29092`,
`rabbitmq:5672`, `postgresql:5432`, `mssqldb:1433`, `redis:6379`, `mailpit:1025` (SMTP).

Admin API (deploy flows from CI):
```sh
TOKEN=$(curl -s http://localhost:1880/auth/token -d "client_id=node-red-admin&grant_type=password&scope=*&username=admin&password=Password123" | jq -r .access_token)
curl -H "Authorization: Bearer $TOKEN" http://localhost:1880/flows
```

https://nodered.org/docs/
