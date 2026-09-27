# .NET Aspire Dashboard (standalone)
Traces, structured logs and metrics for any app that exports OpenTelemetry - no Aspire AppHost required.

Dashboard: http://localhost:18888 (anonymous access is on by default - see `ASPIRE_ALLOW_ANONYMOUS` in `.env`)

Point your app at it:<br>
```
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:18889    # gRPC (default protocol for the .NET exporter)
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_SERVICE_NAME=MyApi
```
From a container on GroupNetwork use `http://aspire-dashboard:18889`.

```csharp
builder.Services.AddOpenTelemetry()
    .WithTracing(t => t.AddAspNetCoreInstrumentation().AddHttpClientInstrumentation())
    .WithMetrics(m => m.AddAspNetCoreInstrumentation().AddRuntimeInstrumentation())
    .UseOtlpExporter();
builder.Logging.AddOpenTelemetry(o => { o.IncludeScopes = true; o.IncludeFormattedMessage = true; });
```

Telemetry is held in memory and is lost when the container restarts. For persistent storage use the
`Observability/OpenTelemetry` stack (Collector + Tempo + Loki + Prometheus/Grafana); the collector config has
an optional exporter that also forwards everything to this dashboard.

If anonymous access is turned off, get the login link with `docker logs aspire-dashboard 2>&1 | grep "login?t="`.
