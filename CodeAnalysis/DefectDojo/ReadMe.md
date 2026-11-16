# DefectDojo
Vulnerability management: imports results from 200+ security tools (Trivy, SonarQube, OWASP ZAP,
Dependency-Track, Semgrep, ...), de-duplicates them, and tracks each finding per product and engagement.

Requires `Databases/PostgreSQL` (the `defectdojo` database is created automatically by the one-shot
`defectdojo-db-init` container; `defectdojo-initializer` then loads the schema and creates the admin user).
The Celery task queue runs on the stack's own Valkey container (`defectdojo-valkey`, no host port).

Web UI and API: http://localhost:8102 (from containers on GroupNetwork: `http://defectdojo:8080`)<br>
Admin: `admin` / `Password123` (from `.env`, applied only when the database is empty)<br>
API docs: http://localhost:8102/api/v2/oa3/swagger-ui/

## Import a scan
Get an API token (UI: user menu → API v2 Key, or from the API):
```sh
curl -X POST http://localhost:8102/api/v2/api-token-auth/ -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Password123"}'
```
Import a Trivy JSON report, creating the product and engagement if they don't exist:
```sh
trivy image --server http://localhost:4954 --token Password123 --format json --output trivy.json myapp:latest
curl -X POST http://localhost:8102/api/v2/import-scan/ -H "Authorization: Token <token>" \
  -F "scan_type=Trivy Scan" -F "file=@trivy.json" \
  -F "product_type_name=Apps" -F "product_name=MyApp" -F "engagement_name=CI" -F "auto_create_context=true"
```
In a pipeline, use `/api/v2/reimport-scan/` with the same fields on later runs: findings that disappeared are
closed instead of piling up as duplicates. Other tools work the same way with their `scan_type`
(e.g. `ZAP Scan`, `SonarQube Scan`, `Dependency Track Finding Packaging Format (FPF) Export`).

## Connecting the other CodeAnalysis stacks
- **SonarQube**: Configuration → Tool Configuration → add *SonarQube* with URL `http://sonarqube:9000` and a SonarQube token, then use the *SonarQube API Import* scan type to pull issues directly.
- **Dependency-Track**: export findings (FPF) or configure Dependency-Track's DefectDojo integration with `http://defectdojo:8080` and an API key.

## Notes
- `DEFECTDOJO_DATABASE_URL` repeats the PostgreSQL login as a URL (`@` in the user name written as `%40`). Keep it in step with `DEFECTDOJO_DB_USER` / `DEFECTDOJO_DB_PASSWORD`.
- `DEFECTDOJO_CREDENTIAL_AES_256_KEY` encrypts credentials stored in Tool Configurations. Don't change it once you have stored any.
- The app and nginx images run as UID 1001 (`CreateVolumes.sh` sets the media folder's owner on Linux).
- Docs: <https://docs.defectdojo.com/>
