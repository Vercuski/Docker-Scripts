# Jaeger v2
Distributed tracing backend and UI, rebuilt on the OpenTelemetry Collector.<br>
UI: http://localhost:16686<br>
OTLP: `http://localhost:14317` (gRPC) / `http://localhost:14318` (HTTP) - from other containers `jaeger:4317` / `jaeger:4318`<br>

```csharp
// OpenTelemetry.Exporter.OpenTelemetryProtocol
builder.Services.AddOpenTelemetry().WithTracing(t => t
    .AddAspNetCoreInstrumentation()
    .AddOtlpExporter(o => o.Endpoint = new Uri("http://localhost:14317")));
```

Traces are stored in an embedded Badger database on the `badger` volume and kept for `JAEGER_RETENTION` (7 days).
Settings are in `config.yaml` (Collector-style configuration).<br>
Jaeger v2's query API lives under `/api/v3`, so Grafana's Jaeger data source is not provisioned; in Grafana use the
Tempo stack (Observability/OpenTelemetry) instead. To send the same telemetry to both, add Jaeger as a second OTLP
exporter in the OpenTelemetry collector.

https://www.jaegertracing.io/docs/
