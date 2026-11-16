# ScyllaDB
C++ rewrite of Apache Cassandra: same CQL protocol and drivers, plus the DynamoDB-compatible Alternator API.<br>
CQL: `localhost:9043` (from other stacks: `scylla:9042`), no authentication<br>
Alternator (DynamoDB API): `http://localhost:8106` (from other stacks: `http://scylla:8000`), any access key / secret<br>
<br>
```csharp
// CassandraCSharpDriver (or ScyllaDB's fork)
var session = Cluster.Builder().AddContactPoint("localhost").WithPort(9043).Build().Connect();

// AWSSDK.DynamoDBv2 against Alternator - a local DynamoDB for development
var dynamo = new AmazonDynamoDBClient(new BasicAWSCredentials("x", "x"),
    new AmazonDynamoDBConfig { ServiceURL = "http://localhost:8106" });
```
Runs in developer mode with 1 CPU shard and 1 GB (tunable in `.env`). Use `NetworkTopologyStrategy` with
`replication_factor: 1` for keyspaces.

https://docs.scylladb.com/
