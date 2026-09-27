# Mailpit
Catches every email your apps send and shows it in a web UI - nothing is delivered to real inboxes.

Web UI: http://localhost:8025<br>
SMTP: `localhost:1025` from the host, `mailpit:1025` from containers on GroupNetwork (no TLS; any username/password accepted)

ASP.NET Core example (`appsettings.Development.json`):
```json
"Smtp": { "Host": "localhost", "Port": 1025, "EnableSsl": false }
```
Mailpit also has a REST API (http://localhost:8025/api/v1/messages) for asserting on emails in integration tests.
