# Kafka (KRaft, single node)
`docker compose up -d`<br>
`docker compose down`<br>

Bootstrap servers<br>
- From the host: `localhost:9092`<br>
- From containers on GroupNetwork: `kafka:29092`<br>

Kafka UI: http://localhost:8084<br>

Create a topic:<br>
`docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test`<br>

Note: data written by the old ZooKeeper-based setup is not compatible with KRaft mode. Empty the
`Messaging/Kafka/Kafka/data` volume folder before the first start.<br>

Use the "Offset Explorer" application to view the kafka queue properties<br>
https://www.kafkatool.com/<br>
