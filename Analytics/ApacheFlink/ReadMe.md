# Apache Flink
Stateful stream (and batch) processing. This is a session cluster: one JobManager plus one TaskManager with 4 task slots.
It pairs with the `Messaging/Kafka` stack for streaming jobs.

Web UI / REST API: http://localhost:8093<br>
From containers on GroupNetwork: `flink-jobmanager:8081`

## Folders
| Container path | Host folder (`$ROOT_VOLUME_DIR/docker/volumes/Analytics/ApacheFlink/...`) | Use |
|---|---|---|
| `/opt/flink/jobs` | `jobs` | Connector JARs and job JARs. JARs uploaded in the web UI are kept here too. |
| `/opt/flink/checkpoints` | `checkpoints` | Checkpoints (`execution.checkpointing.dir`) |
| `/opt/flink/savepoints` | `savepoints` | Default savepoint folder, so jobs can be stopped and resumed |

## Flink SQL with Kafka
The image ships without connectors. Download the Kafka SQL connector once into the `jobs` folder:
<https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/5.0.0-2.2/flink-sql-connector-kafka-5.0.0-2.2.jar>
(the newest connector for Flink 2.x; it works with Flink 2.3).

Start the Kafka stack, then open the SQL client:
```sh
docker exec -it flink-jobmanager ./bin/sql-client.sh
```
```sql
ADD JAR '/opt/flink/jobs/flink-sql-connector-kafka-5.0.0-2.2.jar';

CREATE TABLE orders (id INT, product STRING, amount DOUBLE) WITH (
  'connector' = 'kafka',
  'topic' = 'orders',
  'properties.bootstrap.servers' = 'kafka:29092',
  'properties.group.id' = 'flink-demo',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'json'
);

INSERT INTO orders VALUES (1, 'widget', 9.99), (2, 'gadget', 24.5);
SELECT product, COUNT(*), SUM(amount) FROM orders GROUP BY product;  -- continuous, updates as messages arrive
```
Use `kafka:29092` from Flink (it is a container). `localhost:9092` only works from the host.

A .NET producer writing JSON to the `orders` topic (Confluent.Kafka, `BootstrapServers = "localhost:9092"`) shows up in the query above as it arrives.

## Submitting a JAR job
```sh
docker exec flink-jobmanager ./bin/flink run -d /opt/flink/jobs/my-job.jar
docker exec flink-jobmanager ./bin/flink stop --savepointPath /opt/flink/savepoints <jobId>
docker exec flink-jobmanager ./bin/flink run -s /opt/flink/savepoints/savepoint-xxxx -d /opt/flink/jobs/my-job.jar
```
Or upload the JAR in the web UI (Submit New Job).

## Notes
- More task slots: raise `FLINK_TASK_SLOTS`, or add TaskManagers with `docker compose up -d --scale flink-taskmanager=2` after removing the `container_name` and `ipv4_address` lines from that service.
- `FLINK_VERSION` is pinned to a minor version. Config keys changed in Flink 2.0 (`execution.checkpointing.*` replaced `state.checkpoints.*`), and savepoints are only guaranteed to restore on the same or a newer version.
- Docs: <https://nightlies.apache.org/flink/flink-docs-stable/>
