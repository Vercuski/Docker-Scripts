# Trino
Distributed SQL query engine: one SQL query can join tables that live in different databases.
This stack is a single node (coordinator and worker in one container) with a catalog for each database stack in this repo.

Web UI: http://localhost:8094 (any username, no password)<br>
JDBC: `jdbc:trino://localhost:8094` (DBeaver, DataGrip/Rider, Metabase, Superset)<br>
From containers on GroupNetwork: `http://trino:8080`

## Catalogs
Each file in `etc/catalog` is one catalog. Logins come from this stack's `.env` and must match the database stack's `.env`.

| Catalog | Stack | Query as |
|---|---|---|
| `postgresql` | Databases/PostgreSQL | `postgresql.<schema>.<table>` (database `postgres`, see `TRINO_POSTGRES_DATABASE`) |
| `sqlserver` | Databases/MSSQL | `sqlserver.dbo.<table>` (database `master`, see `TRINO_MSSQL_DATABASE`) |
| `mysql` | Databases/MySQL | `mysql.<database>.<table>` |
| `mongodb` | Databases/MongoDB | `mongodb.<database>.<collection>` |
| `clickhouse` | Databases/ClickHouse | `clickhouse.<database>.<table>` |
| `cassandra` | Databases/ApacheCassandra | `cassandra.<keyspace>.<table>` |
| `tpch` | built in | sample data, e.g. `tpch.tiny.orders` |
| `memory` | built in | scratch tables, lost on restart |

Trino starts even when the database stacks are down; a query against a stopped database fails with a connection error.
Start the stacks you need first. To add another catalog (for example a second Postgres database), copy a file, change the
name and URL, and run `docker compose restart`.

## Examples
```sh
docker exec -it trino trino    # CLI inside the container
```
```sql
SHOW CATALOGS;
SHOW SCHEMAS FROM sqlserver;

-- Join SQL Server orders to Postgres customers
SELECT c.name, sum(o.amount) AS revenue
FROM postgresql.public.customers c
JOIN sqlserver.dbo.orders o ON o.customer_id = c.id
GROUP BY c.name;

-- Copy a Mongo collection into ClickHouse for analytics
CREATE TABLE clickhouse.default_db.products AS SELECT * FROM mongodb.shop.products;
```

## Notes
- **ClickHouse** uses `?compress=0` in its URL. With compression on, the JDBC driver bundled in Trino 484 fails against current ClickHouse servers with *Magic is not correct*.
- **Cassandra** requires the local data center name; the image default is `datacenter1` (`TRINO_CASSANDRA_DC`).
- From .NET, use the HTTP client protocol (`POST /v1/statement` on port 8094, header `X-Trino-User`), or point a BI tool at the JDBC URL.
- `TRINO_MEM_LIMIT` caps the container; the JVM heap is 80% of it.
- Docs: <https://trino.io/docs/current/>
