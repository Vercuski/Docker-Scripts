# Typesense
Typo-tolerant search engine with in-memory indexes (fast, sized by RAM), facets, geo and vector search, and
strict collection schemas. No built-in UI.<br>
API: http://localhost:8137 (from other containers: `http://typesense:8108`)<br>
Health: http://localhost:8137/health<br>

Every request needs the `X-TYPESENSE-API-KEY` header. `TYPESENSE_API_KEY` in `.env` is the bootstrap admin
key; create scoped search-only keys for apps with `POST /keys`.
```sh
curl -X POST http://localhost:8137/collections -H "X-TYPESENSE-API-KEY: <key>" \
  -d '{"name":"movies","fields":[{"name":"title","type":"string"}]}'
curl "http://localhost:8137/collections/movies/documents/search?q=intersteller&query_by=title" -H "X-TYPESENSE-API-KEY: <key>"
```
.NET: the `Typesense` NuGet package (`services.AddTypesenseClient(...)`).
Host port 8137 because Couchbase uses Typesense's default 8108.

https://typesense.org/docs/
