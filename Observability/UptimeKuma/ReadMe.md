# Uptime Kuma
Self-hosted uptime monitoring: HTTP(S), TCP, ping, DNS, Docker containers, databases, gRPC and more, with
notifications (email, Slack, Teams, Discord, webhooks, ...) and public status pages.<br>
UI: http://localhost:3005 - the first visit creates the admin account.<br>
<br>
Uses the embedded SQLite database (`UPTIME_KUMA_DB_TYPE=sqlite` skips the database-choice page). Monitor other stacks
by their GroupNetwork alias, e.g. `http://keycloak:8080/health/ready`, `postgresql:5432`, `http://grafana:3000/api/health`.
For email notifications use Mailpit: SMTP host `mailpit`, port `1025`, no TLS.

https://github.com/louislam/uptime-kuma/wiki
