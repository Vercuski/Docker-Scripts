# RavenDB
ACID document database built in .NET, with the RavenDB Studio UI.<br>
Studio: http://localhost:8105 (unsecured: plain HTTP, no certificate, local development only)<br>
<br>
```csharp
// RavenDB.Client NuGet package
var store = new DocumentStore { Urls = ["http://localhost:8105"], Database = "Shop" }.Initialize();
```
From another container on GroupNetwork use `http://ravendb:8105` and set
`store.Conventions.DisableTopologyUpdates = true`; otherwise the client follows the cluster topology to
`http://localhost:8105`, which only works from the host.<br>
The container listens on the same port numbers as the host because RavenDB calls itself on its public URL.<br>
Create databases from Studio (Databases → New database) or with `store.Maintenance.Server.Send(new CreateDatabaseOperation(...))`.<br>
The built-in licence has limits; paste a free Developer licence JSON into `RAVENDB_LICENSE` to lift them.

https://ravendb.net/docs/
