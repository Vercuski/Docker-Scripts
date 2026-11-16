# TimescaleDB
PostgreSQL 18 with the TimescaleDB extension (hypertables, compression, continuous aggregates, retention).<br>
Connection: `Host=localhost;Port=5433;Database=tsdb;Username=user@user.com;Password=Password123`<br>
(from other stacks: `timescaledb:5432`). Any PostgreSQL client works (Npgsql, EF Core).<br>
<br>
```sql
CREATE TABLE metrics (ts timestamptz NOT NULL, device text, value double precision);
SELECT create_hypertable('metrics', by_range('ts'));
SELECT time_bucket('1 hour', ts) AS hour, avg(value) FROM metrics GROUP BY hour ORDER BY hour;
```
The image tag pins the PostgreSQL major version; changing it on existing data requires `pg_upgrade`.

https://docs.timescale.com/
