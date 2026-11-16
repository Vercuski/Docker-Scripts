# Memcached
In-memory key/value cache. Endpoint: `localhost:11211` (from other stacks: `memcached:11211`).<br>
No persistence and no authentication. Cache size and connection limit are set in `.env`.<br>
<br>
.NET client: `EnyimMemcachedCore` (`services.AddEnyimMemcached(o => o.AddServer("localhost", 11211))`).

https://memcached.org/
