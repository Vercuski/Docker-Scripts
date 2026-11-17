# Apache NiFi
Visual dataflow / ETL (NiFi 2): drag processors onto a canvas to pull, route, transform and push data between
systems - databases over JDBC, Kafka, MQTT, HTTP/REST, S3, SFTP, files - with back-pressure, retries and full
data provenance (what happened to every record).<br>
UI: https://localhost:8155/nifi (`admin` / `Password123!`; from other stacks `https://nifi:8443/nifi`)<br>

- **HTTPS only**, with NiFi's self-signed certificate: accept the browser warning (curl: `-k`).
- **Password needs 12+ characters** (NiFi's single-user rule), hence `Password123!` instead of the repo's usual default.
- Open the UI as `localhost:8155`, not `127.0.0.1:8155`: NiFi rejects host names not in `NIFI_WEB_PROXY_HOST`
  (`docker-compose.yml`), and its HTTPS server rejects IP addresses as the TLS host name (HTTP 400).
- The flow is saved in `conf/flow.json.gz` (conf volume); repositories (flowfile, content, provenance, database,
  state) each have their own volume. `nifi-init` copies the default `conf/` into an empty conf volume.

JDBC drivers: NiFi doesn't ship them. Put the driver JAR (PostgreSQL, SQL Server, ...) in a folder you mount, or
download it into the conf volume, and point a `DBCPConnectionPool` controller service at it, e.g. URL
`jdbc:postgresql://postgresql:5432/<db>` or `jdbc:sqlserver://mssqldb:1433;encrypt=false`.

REST API:
```sh
TOKEN=$(curl -ks -X POST https://localhost:8155/nifi-api/access/token -d "username=admin&password=Password123!")
curl -ks -H "Authorization: Bearer $TOKEN" https://localhost:8155/nifi-api/flow/about
```
Flow versioning: NiFi 2 has Git-based registry clients (GitHub, GitLab, Bitbucket, Azure DevOps) under
*Controller Settings > Registry Clients*; NiFi Registry is not included here.

https://nifi.apache.org/documentation/
