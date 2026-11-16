# OWASP Dependency-Track (v5)
Keeps an inventory of every component your projects ship (from CycloneDX SBOMs) and continuously matches them
against vulnerability databases (NVD, GitHub Advisories, OSV), with policy rules and license tracking.

Requires `Databases/PostgreSQL` (the `dtrack` database is created automatically on first start by the one-shot
`dtrack-db-init` container).

Web UI: http://localhost:8099<br>
REST API: http://localhost:8098/api (from containers on GroupNetwork: `http://dtrack-apiserver:8080/api`)<br>
First login: `admin` / `admin`; you must set a new password straight away.

The API server mirrors the vulnerability databases from the internet in the background after the first start,
so findings appear some minutes after a project is uploaded.

## Create an SBOM and upload it
An SBOM for a .NET solution, with the CycloneDX tool:
```sh
dotnet tool install --global CycloneDX
dotnet CycloneDX MySolution.sln -o ./sbom      # see `dotnet CycloneDX --help` for output options (JSON/XML)
```
Or with Trivy (see `CodeAnalysis/Trivy`), from source, a build output folder or a container image:
```sh
trivy fs --format cyclonedx --output bom.json ./src
trivy image --format cyclonedx --output bom.json myapp:latest
```
Upload it (creates the project if it doesn't exist). Create the API key in the UI under
**Administration → Access Management → Teams → Automation** (give the team the `BOM_UPLOAD` and
`PROJECT_CREATION_UPLOAD` permissions):
```sh
curl -X POST http://localhost:8098/api/v1/bom \
  -H "X-Api-Key: <api key>" \
  -F "projectName=MyApp" -F "projectVersion=1.0.0" -F "autoCreate=true" \
  -F "bom=@bom.json"
```
The same upload works from a CI pipeline (the Gitea runner can reach `http://dtrack-apiserver:8080`).

## Notes
- v5 runs only on PostgreSQL. `DTRACK_APISERVER_MEM_LIMIT` caps the API server; it needs about 2 GB.
- The frontend is a single-page app that calls the API from your browser, so `API_BASE_URL` is the host URL (`http://localhost:8098`). If you change `DTRACK_API_PORT`, the frontend picks it up automatically.
- Docs: <https://docs.dependencytrack.org/>
