# Metabase
Self-service BI: point-and-click questions, dashboards, a SQL editor and alerts.<br>
Web UI + API: http://localhost:3008 (admin@example.com / Password123)<br>

Requires the **PostgreSQL** stack: `metabase-db-init` creates the `metabase` role and database for Metabase's
own data, and `metabase-init` completes the "Let's get started" setup (admin account, site name, tracking off).
It skips once Metabase is set up. `METABASE_PASSWORD_COMPLEXITY=weak` lets the repo's `Password123` through;
Metabase's normal policy rejects it as too common.

Add data in **Admin > Databases** using GroupNetwork names: SQL Server `mssqldb:1433`, PostgreSQL `postgresql`,
MySQL `mysqldb`, MongoDB `mongodb`, ClickHouse `clickhouse`, and so on. Drivers for these ship with Metabase.

`METABASE_ENCRYPTION_KEY` encrypts the saved connection details: keep it if you recreate the stack.

https://www.metabase.com/docs/latest/
