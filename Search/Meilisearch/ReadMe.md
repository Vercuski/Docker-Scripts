# Meilisearch
Typo-tolerant instant search with filters, facets, sorting and hybrid/vector search.<br>
API + mini dashboard: http://localhost:7700 (from other containers: `http://meilisearch:7700`)<br>

All requests need a key. The master key (`MEILI_MASTER_KEY` in `.env`) is for managing keys; Meilisearch also
creates default **Search**, **Admin** and **Read-Only Admin** keys. List them with:
```sh
curl http://localhost:7700/keys -H "Authorization: Bearer <MEILI_MASTER_KEY>"
```
Paste the search key into the mini dashboard. In .NET, use the `Meilisearch` NuGet package:
```csharp
var client = new MeilisearchClient("http://localhost:7700", "<admin key>");
await client.Index("movies").AddDocumentsAsync(movies);
var hits = await client.Index("movies").SearchAsync<Movie>("intersteller");
```
`MEILI_ENV=production` turns the dashboard off and makes the master key mandatory.

https://www.meilisearch.com/docs
