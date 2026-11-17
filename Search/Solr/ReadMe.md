# Apache Solr
Lucene-based search server (Solr 10) in standalone mode.<br>
Admin UI + API: http://localhost:8983/solr/ (from other containers: `http://solr:8983/solr/`)<br>

On the first start the core named by `SOLR_CORE` (`dev`) is created with the default schemaless configset;
later starts reuse it. Index and query:
```sh
curl -X POST "http://localhost:8983/solr/dev/update?commit=true" -H "Content-Type: application/json" \
  -d '[{"id":"1","title":"Interstellar"}]'
curl "http://localhost:8983/solr/dev/select?q=title:intersteller~1"
```
More cores: `docker exec solr solr create -c <name>`. Authentication is off (local development only).
.NET: the `SolrNet` NuGet package, or plain HTTP/JSON.

https://solr.apache.org/guide/solr/latest/
