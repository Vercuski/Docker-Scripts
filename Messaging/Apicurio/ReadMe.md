# Apicurio Registry 3
Schema and API registry: Avro, Protobuf and JSON Schema for Kafka messages, plus OpenAPI / AsyncAPI documents, with
versioning and compatibility rules.<br>
UI: http://localhost:8120 · API: http://localhost:8119/apis/registry/v3<br>
Confluent-compatible API: `http://localhost:8119/apis/ccompat/v7` (from other containers:
`http://apicurio-registry:8080/apis/ccompat/v7`)<br>
<br>
Requires the **PostgreSQL** stack (`apicurio-db-init` creates the `apicurio` role and database). Kafka UI in the
Kafka stack is pointed at the Confluent-compatible API, so its Schema Registry page shows these schemas.

```csharp
// Confluent.SchemaRegistry + Confluent.SchemaRegistry.Serdes.Avro work against the ccompat endpoint
var registry = new CachedSchemaRegistryClient(new SchemaRegistryConfig { Url = "http://localhost:8119/apis/ccompat/v7" });
```

https://www.apicur.io/registry/docs/
