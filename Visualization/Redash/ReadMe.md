# Redash
Query editor (SQL and MongoDB, Elasticsearch, etc.), visualizations, dashboards, scheduled refreshes and alerts.<br>
Web UI + API: http://localhost:8143 (admin@example.com / Password123)<br>

Requires the **PostgreSQL** stack (Redash's own database) and the **Redis** stack (job queues, DB 3).
`redash-db-init` creates the role and database. `redash-init` creates tables on an empty database, applies
migrations on an existing one, and creates the first admin. Then the server, scheduler and worker start.
One worker container serves every queue.

Add data sources in **Settings > Data Sources** by GroupNetwork name (`mssqldb`, `postgresql`, `mysqldb`,
`mongodb`, ...). For the API, use the key on your profile page:
```sh
curl -H "Authorization: Key <api key>" http://localhost:8143/api/queries
```
Gunicorn is bound to `0.0.0.0` (`REDASH_GUNICORN_BIND`) because its default `[::]` fails on a network without
IPv6. `REDASH_SECRET_KEY` encrypts stored data source credentials: keep it if you recreate the stack.

https://redash.io/help/
