# Garnet
Microsoft Research's Redis-compatible cache server, written in C#/.NET.<br>
Endpoint: `localhost:6380` (from other stacks: `garnet:6379`), password `Password123`<br>
<br>
Works with StackExchange.Redis and `Microsoft.Extensions.Caching.StackExchangeRedis`:
```csharp
var redis = await ConnectionMultiplexer.ConnectAsync("localhost:6380,password=Password123");
```
Data is checkpointed to the data folder on `SAVE` / `BGSAVE` (and on shutdown) and recovered on start (`--recover`).
Not every Redis command is implemented; see the compatibility list.

https://microsoft.github.io/garnet/
