# JupyterLab
Notebooks with Python, pandas and PySpark (the Jupyter project's `pyspark-notebook` image). It works on its own and
pairs with the `Analytics/Apache Spark` cluster and `Analytics/Trino`.

URL: http://localhost:8888/lab?token=Password123 (token is `JUPYTERLAB_TOKEN`)<br>
Spark UI of a notebook's running Spark session: http://localhost:4040

## Folders
| Container path | Host folder | Use |
|---|---|---|
| `/home/jovyan/work` | `Analytics/JupyterLab/work` | Your notebooks |
| `/opt/spark/data` | `Analytics/ApacheSpark/data` | Shared with the Spark master and worker. Data that cluster jobs read or write goes here. |

## Spark
Local mode (no cluster needed):
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local[*]").getOrCreate()
```
On the Spark stack's cluster (start `Analytics/Apache Spark` first):
```python
import os
from pyspark.sql import SparkSession, functions as F
spark = SparkSession.builder.master(os.environ["SPARK_MASTER"]).appName("notebook").getOrCreate()  # spark://apachespark:7077

df = spark.range(1_000_000).withColumn("bucket", F.col("id") % 3)
df.write.mode("overwrite").parquet("/opt/spark/data/demo.parquet")   # executors write here too
spark.read.parquet("/opt/spark/data/demo.parquet").groupBy("bucket").count().show()
```
- Executors run in the Spark containers and only see `/opt/spark/data`. Paths under `/home/jovyan/work` fail on the cluster.
- **Python UDFs and RDD lambdas only work in local mode.** The notebook runs Python 3.13 and the `spark` image's workers run Python 3.10, and PySpark refuses mixed minor versions. Built-in DataFrame functions and SQL run fine on the cluster.
- The image's Spark version must equal the cluster's. `JUPYTERLAB_VERSION=spark-4.3.0` matches `spark:latest` today; if the Spark stack moves on, change both together.
- The notebook user runs as UID 185 (Spark's user) so files written by the notebook and by the executors have the same owner on Linux. The container starts as root only to make that switch.

## Trino
```python
%pip install trino
```
```python
import os, trino, pandas as pd
conn = trino.dbapi.connect(host=os.environ["TRINO_HOST"], port=8080, user="jovyan")   # trino:8080 inside GroupNetwork
pd.read_sql("SELECT * FROM postgresql.public.customers", conn)
```
Packages installed with `%pip` last until the container is re-created.

## Notes
- When the Spark stack is already running, `docker compose up` warns that volume `spark_data` was created by another project. That is expected: both stacks define the same folder, so either can start first.
- Docker Hub's `jupyter/*` images stopped updating in 2023. This stack uses `quay.io/jupyter/pyspark-notebook`.
- Docs: <https://jupyter-docker-stacks.readthedocs.io/>
