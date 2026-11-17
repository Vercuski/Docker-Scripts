# Apache Superset
SQL Lab, charts and dashboards over your databases.<br>
Web UI + API: http://localhost:8142 (admin / Password123)<br>

Requires the **PostgreSQL** stack for Superset's metadata. The first `docker compose up` builds `superset-drivers`
from `./image`: the official image ships without database drivers, so it adds `psycopg2` (PostgreSQL),
`pymssql` (SQL Server) and `pymysql` (MySQL/MariaDB). Add others to `image/Dockerfile`, then
`docker compose up -d --build`.

On every start `superset-init` applies migrations, creates the admin (or resets its password to the `.env`
value) and syncs roles. Settings live in `superset_config.py`. There's no Celery or Redis here, so queries run
synchronously and results aren't cached across restarts.

Database connections (**Settings > Database Connections**):

| Database | SQLAlchemy URI |
|---|---|
| SQL Server stack | `mssql+pymssql://sa:Password123@mssqldb:1433/master` |
| PostgreSQL stack | `postgresql+psycopg2://user%40user.com:Password123@postgresql:5432/postgres` |
| MySQL stack | `mysql+pymysql://root:Password123@mysqldb:3306/mysql` |

`SUPERSET_SECRET_KEY` encrypts stored database passwords: keep it if you recreate the stack.

https://superset.apache.org/docs/intro
