# Grafana Pyroscope
Continuous profiling: CPU, allocations, lock contention and exceptions over time, per service.<br>
UI: http://localhost:4041 · from other containers: `http://pyroscope:4040`<br>
Grafana (Visualization/Grafana) has it provisioned as the **Pyroscope** data source (Explore → Profiles).<br>
<br>
.NET: the Pyroscope .NET profiler (the `Pyroscope` NuGet package plus a native CLR profiler enabled through
`CORECLR_*` environment variables) pushes profiles to `http://localhost:4041` - see the .NET SDK page below for the
exact variables and where to get the profiler binaries. Grafana Alloy can also collect and forward profiles.

https://grafana.com/docs/pyroscope/latest/configure-client/language-sdks/dotnet/
