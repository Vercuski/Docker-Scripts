# Sonatype Nexus Repository CE
Universal repository manager: hosted, proxy (cache) and group repositories for NuGet, npm, Docker, Maven, PyPI, Helm,
Go, raw files and more.<br>
UI: http://localhost:8125 (`admin` / `Password123`; from other containers `http://nexus:8081`)<br>

| Feed | URL |
|---|---|
| NuGet (your packages + nuget.org cache) | `http://localhost:8125/repository/nuget-group/index.json` |
| NuGet push | `http://localhost:8125/repository/nuget-hosted/` |

```sh
dotnet nuget add source http://localhost:8125/repository/nuget-group/index.json -n nexus
dotnet nuget push MyLib.1.0.0.nupkg -s http://localhost:8125/repository/nuget-hosted/ -k <NuGet API key>
```
The NuGet API key is under *(user menu) → NuGet API Key*. npm, Docker and other formats: create the repositories in
*Settings → Repositories* (the npm-token and Docker-token realms are already active).

## nexus-init
Does what the first-login wizard would: enables anonymous **read** access and the NuGet API-key / npm / Docker token
realms. With `NEXUS_ACCEPT_EULA=true` it also accepts the Community Edition EULA
(https://links.sonatype.com/products/nxrm/ce-eula) and acknowledges its mandatory telemetry; Nexus refuses uploads
until both are done. Set it to `false` to accept them yourself in the UI.<br>
Community Edition has usage limits (stored components and requests per day) that a dev machine stays well under.<br>
The admin password from `.env` only applies on the very first start.

https://help.sonatype.com/en/sonatype-nexus-repository.html
