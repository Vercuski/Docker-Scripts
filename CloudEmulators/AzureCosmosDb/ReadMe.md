# Azure Cosmos DB emulator (vNext)
NoSQL API emulator. Data Explorer: http://localhost:1234

Host port 8081 is reserved for this emulator (MediaWiki moved to 8281) because the Data Explorer always
calls `localhost:8081`.

Connection string (well-known emulator key):<br>
`AccountEndpoint=https://localhost:8081/;AccountKey=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==;`

The emulator uses a self-signed certificate. For local development in .NET:
```csharp
var client = new CosmosClient(connectionString, new CosmosClientOptions
{
    ConnectionMode = ConnectionMode.Gateway,
    HttpClientFactory = () => new HttpClient(new HttpClientHandler
    {
        ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator
    })
});
```
Alternatively export the certificate from the browser (https://localhost:8081) and import it into
"Trusted Root Certification Authorities", or set `COSMOSDB_PROTOCOL=http` for SDKs that support plain HTTP.

The vNext emulator supports the NoSQL API in gateway mode only.
