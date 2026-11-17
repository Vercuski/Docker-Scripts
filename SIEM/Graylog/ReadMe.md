# Graylog
Graylog Open 7: centralized log management, search, dashboards, streams and alerts.<br>
Web UI + API: http://localhost:9004 (admin / Password123)<br>

Three containers: the Graylog server, the **Graylog Data Node** (runs and manages OpenSearch for Graylog), and
MongoDB 8.0 for configuration. `GRAYLOG_SELFSIGNED_STARTUP=true` makes the server create its internal CA and
provision the data node's certificates on the first start, so Graylog's preflight setup wizard is skipped and
the UI is ready once the server reports "up and running" (1-2 minutes).

MongoDB is part of this stack, not the shared `Databases/MongoDB` one: Graylog 7.2 supports MongoDB 7.x-8.3.x,
and that stack floats on `latest` (9.x).

## Sending logs
Inputs are created in **System > Inputs** (or the API). The stack publishes these ports for them:

| Input type | Port |
|---|---|
| GELF UDP / GELF TCP | 12201 |
| Syslog UDP / TCP | 5140 |
| Beats | 5044 |

.NET with Serilog (`Serilog.Sinks.Graylog`):
```csharp
.WriteTo.Graylog(new GraylogSinkOptions { HostnameOrAddress = "localhost", Port = 12201, TransportType = TransportType.Udp })
```
Containers on `GroupNetwork` send to `graylog:12201`; any container can also use Docker's `gelf` log driver
(`--log-driver gelf --log-opt gelf-address=udp://localhost:12201`). Custom GELF fields lose their leading
underscore: `_OrderId` is searched as `OrderId:42`.

## Host requirement
OpenSearch needs `vm.max_map_count` of at least 262144 on the Docker host (same as the Elastic stack):<br>
`wsl -d docker-desktop` then `sysctl -w vm.max_map_count=262144`

https://go2docs.graylog.org/current/home.htm
