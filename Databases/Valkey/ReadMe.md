# Valkey
The Linux Foundation's BSD-licensed continuation of Redis (forked from Redis 7.2), protocol compatible with Redis clients.<br>
Endpoint: `localhost:6381` (from other stacks: `valkey:6379`), password `Password123`<br>
<br>
```csharp
var redis = await ConnectionMultiplexer.ConnectAsync("localhost:6381,password=Password123");
```
Persistence: append-only file in the data folder.

https://valkey.io/
