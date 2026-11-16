# Qdrant
Vector database for semantic search / RAG (lighter alternative to the Milvus stack).<br>
REST API + dashboard: http://localhost:6333/dashboard (enter the API key `Password123`)<br>
gRPC: `localhost:6334` (from other stacks: `qdrant:6334`)<br>
<br>
```csharp
// Qdrant.Client NuGet package (gRPC)
var client = new QdrantClient("localhost", 6334, apiKey: "Password123");
// Semantic Kernel: Microsoft.SemanticKernel.Connectors.Qdrant
```
Clients send the key as the `api-key` header; set `QDRANT_API_KEY=` (empty) in `.env` to turn authentication off.

https://qdrant.tech/documentation/
