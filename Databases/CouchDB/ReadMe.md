# Apache CouchDB
JSON document database with an HTTP API, multi-master replication and the Fauxton UI.<br>
Fauxton: http://localhost:5984/_utils (`admin` / `Password123`)<br>
API: `http://localhost:5984` (from other stacks: `http://couchdb:5984`)<br>
<br>
`couchdb-init` runs CouchDB's single-node setup once, which creates the `_users` and `_replicator` system databases.
It exits immediately on later starts.<br>
.NET client: `CouchDB.NET` (LINQ queries over Mango).

https://docs.couchdb.org/
