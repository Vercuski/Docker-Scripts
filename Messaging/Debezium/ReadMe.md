# Debezium (Kafka Connect)
Change data capture: streams inserts, updates and deletes from databases into Kafka topics.<br>
Requires the **Kafka** stack. REST API: http://localhost:8118 - connectors are also visible and manageable in
Kafka UI (http://localhost:8084 → Kafka Connect).<br>
Connectors included: PostgreSQL, SQL Server, MySQL, MariaDB, MongoDB, Oracle, Db2, Informix, Spanner, Vitess,
CockroachDB and the JDBC sink.

## PostgreSQL example
The PostgreSQL stack runs with `wal_level=logical` for this (restart it once after updating). Register the sample
connector, which captures every table in the `public` schema of the `postgres` database:
```sh
curl -X POST -H "Content-Type: application/json" --data @postgres-connector.json http://localhost:8118/connectors
curl http://localhost:8118/connectors/postgres-cdc/status
```
Changes appear on topics named `pg.<schema>.<table>` (e.g. `pg.public.customers`) as JSON with `op`
(`r` snapshot, `c` insert, `u` update, `d` delete), `before` and `after`. `before` is only filled when the table has
`ALTER TABLE ... REPLICA IDENTITY FULL`.

## SQL Server
CDC must be enabled on the database and tables (`EXEC sys.sp_cdc_enable_db` / `sys.sp_cdc_enable_table`) and SQL
Server Agent must run (`MSSQL_AGENT_ENABLED=true`). Use `io.debezium.connector.sqlserver.SqlServerConnector` with
`database.hostname: mssqldb`.

https://debezium.io/documentation/
