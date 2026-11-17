# Apache Airflow
Python-defined DAG scheduler for data pipelines and batch jobs (Airflow 3, LocalExecutor).<br>
UI + REST API: http://localhost:8136 (admin / Password123)<br>

Requires the **PostgreSQL** stack (`airflow-db-init` creates the `airflow` role and database). `airflow-init` runs
the database migrations and creates the admin user (or resets its password to the `.env` value) on every start,
then the API server, scheduler, DAG processor and triggerer start.

DAGs go in `./dags`; new files are picked up within about 30 seconds and start paused. The sample
`hello_dotnet_stack.py` runs every 5 minutes and checks two other stacks over `GroupNetwork`.
Task logs are in the `logs` volume. Extra Python packages: `AIRFLOW_PIP_ADDITIONAL_REQUIREMENTS` (installed on
every start, so slow), or build an image `FROM apache/airflow:3.4.0` for anything permanent.

REST API (token auth):
```sh
curl -X POST http://localhost:8136/auth/token -H "Content-Type: application/json" -d '{"username":"admin","password":"Password123"}'
curl http://localhost:8136/api/v2/dags -H "Authorization: Bearer <access_token>"
```
Tasks run inside the scheduler container (LocalExecutor). For parallel workers, switch to the CeleryExecutor
from the official compose file (adds Redis and worker containers).

https://airflow.apache.org/docs/apache-airflow/stable/
