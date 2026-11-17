# Langfuse
Open-source LLM engineering platform (v4): traces of every LLM call with prompts, outputs, token counts, cost and
latency; prompt management and versioning; datasets, evaluations and scores; an OpenTelemetry endpoint.<br>
UI: http://localhost:3014 (`admin@example.com` / `Password123`) - from other stacks `http://langfuse-web:3000`<br>
Project API keys: public `pk-lf-local-dev`, secret `sk-lf-local-dev` (project **Local dev**, organisation **Docker-Scripts**)<br>

Langfuse v4 is several services. This stack runs `langfuse-web` (UI, API, ingestion), `langfuse-worker` (processes
events into ClickHouse) and its own **ClickHouse** (26.3, the version Langfuse tests; it needs 25.12 or newer, and the
Databases/ClickHouse stack floats on `latest`). It uses three other stacks:

| Stack | Used for | Set up by |
|---|---|---|
| PostgreSQL | users, projects, prompts, settings | `langfuse-db-init` (role + database `langfuse`) |
| Redis | job queue and cache, DB 5 | - |
| ObjectStorage/RustFS | raw events and media, bucket `langfuse` | `langfuse-s3-init` |

On the first start `LANGFUSE_INIT_*` create the admin, organisation, project and the fixed API keys above; sign-up is
off. The LiteLLM stack already sends its traces here.

**v4 ingestion is OpenTelemetry only** (`/api/public/otel/v1/traces`); the legacy `/api/public/ingestion` endpoint
is refused, so use current SDKs or any OTel exporter:
```csharp
// .NET: plain OpenTelemetry (OpenTelemetry.Exporter.OpenTelemetryProtocol), e.g. with Microsoft.Extensions.AI / Semantic Kernel spans
var auth = Convert.ToBase64String(Encoding.UTF8.GetBytes("pk-lf-local-dev:sk-lf-local-dev"));
builder.Services.AddOpenTelemetry().WithTracing(t => t
    .AddSource("Microsoft.Extensions.AI", "Microsoft.SemanticKernel*")
    .AddOtlpExporter(o => {
        o.Endpoint = new Uri("http://localhost:3014/api/public/otel/v1/traces");
        o.Protocol = OtlpExportProtocol.HttpProtobuf;
        o.Headers = $"Authorization=Basic {auth}";
    }));
```
```sh
curl -u pk-lf-local-dev:sk-lf-local-dev "http://localhost:3014/api/public/v2/observations?limit=5"
```
Langfuse recommends about 2 CPU / 4 GB each for web and worker and 8 GB for ClickHouse in production; locally it runs
in far less, but give Docker Desktop enough memory if you run it together with Ollama.

https://langfuse.com/docs
