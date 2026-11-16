# Couchbase Server (Community Edition)
Document database with a built-in key/value cache, SQL++ queries, secondary indexes and full-text search.<br>
Web console: http://localhost:8107 (`Administrator` / `Password123`). Bucket `dev` is created on first start.<br>
<br>
```csharp
// CouchbaseNetClient NuGet package
var cluster = await Cluster.ConnectAsync("couchbase://localhost", "Administrator", "Password123");
var collection = (await cluster.BucketAsync("dev")).DefaultCollection();
```
From another container on GroupNetwork use `couchbase://couchbase`.<br>
<br>
Ports 8091-8096 are taken by other stacks, so the web console and services are published on 8107-8110.
`couchbase-init` registers these as the node's *external alternate addresses* (hostname `localhost`), which the SDK
picks up automatically when it connects through `localhost`. The node is named by its static IP (172.20.6.180)
because Couchbase rejects short host names.<br>
<br>
Community Edition notes: data, index, query and search services only (no analytics or eventing); buckets use the
Couchstore storage engine (Magma is Enterprise-only).

https://docs.couchbase.com/server/current/
