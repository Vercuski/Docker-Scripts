# KurrentDB (formerly EventStoreDB)
Admin UI: http://localhost:2113 (insecure mode, no login)<br>
Connection string: `kurrentdb://localhost:2113?tls=false` (from other stacks: `kurrentdb://kurrentdb:2113?tls=false`;
the old `eventstoredb` alias still resolves)<br>
.NET client: `KurrentDB.Client` NuGet package (`EventStore.Client.Grpc.*` 23.x+ also connects with `esdb://`).<br>
<br>
This replaces the EventStoreDB 20.10 stack. Differences from the old stack:
- gRPC only: the legacy TCP protocol and port 1113 were removed in v24.
- Settings are `KURRENTDB_*` (the `EVENTSTORE_*` names are still accepted but deprecated).
- New data folder `docker/volumes/Databases/KurrentDB`; the old `Databases/EventStoreDb` folder is left untouched.
  KurrentDB can open a 20.10 database in place (it upgrades it), so to keep old streams copy the old `data`
  folder into the new one **before the first start**.

https://docs.kurrent.io/server/
