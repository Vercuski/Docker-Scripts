# Redpanda + Redpanda Console
Kafka-API compatible streaming platform written in C++ (no JVM, no ZooKeeper), with a built-in Schema Registry and
HTTP proxy. A lighter alternative to the Kafka stack; `Confluent.Kafka` clients work unchanged.<br>
<br>
Kafka API: `localhost:19092` (from other containers: `redpanda:9092`)<br>
Schema Registry: http://localhost:18081 (from other containers: `http://redpanda:8081`)<br>
HTTP proxy: http://localhost:18082 · Admin API: http://localhost:9644<br>
Console (topics, consumer groups, schemas): http://localhost:8116<br>
<br>
CLI: `docker exec -it redpanda rpk topic create orders` / `rpk topic consume orders`<br>
Runs in dev-container mode with 1 core and 1 GB (tunable in `.env`). No authentication.

https://docs.redpanda.com/
