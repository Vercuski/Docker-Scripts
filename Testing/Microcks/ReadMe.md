# Microcks
CNCF tool for API mocking and contract testing from your specs: OpenAPI, AsyncAPI, gRPC/Protobuf, GraphQL, SOAP/WSDL
and Postman collections. Each named example in a spec becomes a mock response.<br>
UI + API: http://localhost:8148 (no login) - gRPC mocks: `localhost:9005`<br>

This is the all-in-one `microcks-uber` image (embedded in-memory database, no Keycloak, no async/Kafka minion), the
same one Microcks' Testcontainers module uses. Its data does not survive a restart, so **`microcks-init` uploads every
file in `artifacts/`** (except `*.md`) on each `docker compose up -d`. Keep your contracts there.

Sample `artifacts/order-api.yaml`:
```sh
curl http://localhost:8148/rest/Order+API/1.0.0/orders/42     # example "shipped"
curl http://localhost:8148/rest/Order+API/1.0.0/orders/43     # example "pending"
```
Mock URL pattern: `/rest/<API name>/<version>/<path>` (spaces as `+`); from other stacks use `http://microcks:8080`.
Upload another artifact at run time:
```sh
curl -F "file=@my-api.yaml" "http://localhost:8148/api/artifact/upload?mainArtifact=true"
```
Contract tests: *Tests > New test* against your running service (e.g. `http://host.docker.internal:5000`).
Re-import after editing `artifacts/`, or after Docker restarted Microcks on its own (e.g. host reboot - the one-shot
init doesn't rerun then): `docker compose up -d --force-recreate microcks-init`.

https://microcks.io/documentation/
