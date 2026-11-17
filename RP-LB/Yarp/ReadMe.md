# YARP
Microsoft's reverse proxy library for .NET, hosted in the small ASP.NET Core app in `src/` (built on the first
`docker compose up`; there is no stable official YARP image).<br>
Proxy: http://localhost:8129/web/ (round-robins over the Nginx and Apache stacks, like HAProxy)<br>
Health: http://localhost:8129/healthz<br>

Routes, clusters, load balancing, active health checks and transforms live in the `ReverseProxy` section of
`config/proxy.json`. The `config` folder is mounted into the container and polled for changes, so edits apply
within a few seconds without a rebuild.

Rebuild after changing `Program.cs` (custom middleware, auth, code-based transforms) or `YARP_PACKAGE_VERSION`:
```sh
docker compose up -d --build
```
The same project runs outside Docker: copy `config/` into `src/` and `dotnet run` there (destinations like `http://nginx:80/` only
resolve inside `GroupNetwork`; point them at `http://localhost:<port>/` when running locally).

https://learn.microsoft.com/aspnet/core/fundamentals/servers/yarp/yarp-overview
