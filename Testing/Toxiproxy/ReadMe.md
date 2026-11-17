# Toxiproxy
TCP proxy for resilience and chaos testing: put it between your app and a dependency, then add **toxics**
(latency, jitter, bandwidth limits, timeouts, connection resets, slicing) to check timeouts, retries and circuit
breakers (Polly, MassTransit retry, EF Core connection resiliency).<br>
REST API: http://localhost:8474 (from other stacks: `http://toxiproxy:8474`)<br>

Proxies from `config/toxiproxy.json` (edit it to add more, then `docker compose restart`):

| Proxy | Host port / GroupNetwork address | Upstream |
|---|---|---|
| postgresql | `localhost:15432` / `toxiproxy:15432` | `postgresql:5432` |
| mssql | `localhost:11433` / `toxiproxy:11433` | `mssqldb:1433` |
| redis | `localhost:16379` / `toxiproxy:16379` | `redis:6379` |
| rabbitmq | `localhost:15673` / `toxiproxy:15673` | `rabbitmq:5672` |
| wiremock | `localhost:18147` / `toxiproxy:18147` | `wiremock:8080` |

The upstream stack must be running; a proxy whose upstream is down just refuses connections.

```sh
# 800 ms latency on everything WireMock sends back
curl -X POST http://localhost:8474/proxies/wiremock/toxics \
  -d '{"name":"lag","type":"latency","stream":"downstream","attributes":{"latency":800}}'
curl -X DELETE http://localhost:8474/proxies/wiremock/toxics/lag
# take SQL Server "down" and back up
curl -X POST http://localhost:8474/proxies/mssql -d '{"enabled":false}'
curl -X POST http://localhost:8474/proxies/mssql -d '{"enabled":true}'
```
From .NET tests, the `Toxiproxy.Net` client (or plain HttpClient calls to the API) can add and remove toxics per test.
CLI inside the container: `docker exec toxiproxy /toxiproxy-cli list`.

https://github.com/Shopify/toxiproxy
