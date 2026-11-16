# Trivy (server mode)
Aqua Security's scanner for vulnerabilities, leaked secrets, IaC misconfigurations and licenses in container images,
file systems (including .NET/NuGet projects), Git repos and Kubernetes. This stack runs it as a **server** that
downloads and keeps the vulnerability database up to date; clients scan locally and ask the server for matches, so
each machine or pipeline doesn't download the database itself.

Server: http://localhost:4954 (from containers on GroupNetwork: `http://trivy:4954`)<br>
Token: `Password123` (`TRIVY_SERVER_TOKEN`)<br>
Health: http://localhost:4954/healthz

On first start the server downloads the database (about 135 MB, 1.7 GB unpacked) into `CodeAnalysis/Trivy/cache`,
so the first scans wait a minute.

## Scanning with the server
Install the client (`winget install AquaSecurity.Trivy`, Scoop, Chocolatey, or use the Docker image), then:
```sh
# A container image
trivy image --server http://localhost:4954 --token Password123 myapp:latest
# A .NET solution folder (NuGet lock files, *.deps.json, build output)
trivy fs --server http://localhost:4954 --token Password123 ./src
# Only what matters, failing a pipeline step
trivy image --server http://localhost:4954 --token Password123 --severity HIGH,CRITICAL --exit-code 1 myapp:latest
```
With Docker instead of a local install (the socket lets Trivy read your local images):
```sh
docker run --rm --network host -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.76.2 \
  image --server http://localhost:4954 --token Password123 myapp:latest
```
Environment variables work too: `TRIVY_SERVER=http://localhost:4954`, `TRIVY_TOKEN=Password123`.

## Feeding other stacks
- **DefectDojo**: `--format json --output trivy.json`, then import it as scan type *Trivy Scan* (see `CodeAnalysis/DefectDojo`).
- **Dependency-Track**: `--format cyclonedx --output bom.json` creates an SBOM to upload (see `CodeAnalysis/DependencyTrack`).

## Notes
- Misconfiguration and secret scanning run entirely in the client; only vulnerability matching uses the server.
- Docs: <https://trivy.dev/latest/docs/references/modes/client-server/>
