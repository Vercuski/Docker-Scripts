# Superset images ship without database drivers; add the ones this repo's stacks need.
ARG SUPERSET_VERSION=6.1.0
FROM apache/superset:${SUPERSET_VERSION}
USER root
# psycopg2: PostgreSQL (also Superset's own metadata DB) - pymssql: SQL Server - pymysql: MySQL/MariaDB
RUN uv pip install --python /app/.venv/bin/python --no-cache psycopg2-binary pymssql pymysql
USER superset
