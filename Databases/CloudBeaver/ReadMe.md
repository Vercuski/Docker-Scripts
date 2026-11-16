# CloudBeaver
DBeaver's browser-based SQL client. UI: http://localhost:8978 (admin `cbadmin` / `Password123`)<br>
<br>
The server configures itself on first start (no setup wizard) and `initial-data-sources.conf` seeds shared connections to:
PostgreSQL, TimescaleDB, SQL Server (`mssqldb`), MySQL (`mysqldb`), MariaDB and ClickHouse.
Each target stack must be running for its connection to open. Log in as the admin to see them.<br>
<br>
The seed file is only read when the workspace is empty. After that, add or edit connections in the UI
(they are saved in the workspace volume). To re-seed, stop the stack and empty the `workspace` folder.

https://dbeaver.com/docs/cloudbeaver/
