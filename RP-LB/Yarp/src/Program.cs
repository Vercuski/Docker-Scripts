// Minimal YARP host: routes, clusters, load balancing and health checks come from the "ReverseProxy"
// section of config/proxy.json (mounted as a folder in the container and reloaded on change).
// Add custom middleware, transforms or auth here like in any ASP.NET Core app.
var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddJsonFile(
    Path.Combine(builder.Environment.ContentRootPath, "config", "proxy.json"), optional: true, reloadOnChange: true);

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));
builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapHealthChecks("/healthz");
app.MapReverseProxy();

app.Run();
