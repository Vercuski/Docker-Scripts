# n8n
Visual workflow automation: schedule, webhook and queue triggers, 400+ integrations (HTTP, databases, Slack,
GitHub...), and JavaScript/Python Code nodes.<br>
UI, REST API and webhooks: http://localhost:5678 (admin@example.com / Password123)<br>

Requires the **PostgreSQL** stack (`n8n-db-init` creates the `n8n` role and database). `n8n-init` creates the owner
account on the first start (the same as the "Set up owner account" page); later starts skip it. Code nodes run in
the `n8n-runners` container (JavaScript and Python), which connects to n8n with `N8N_RUNNERS_AUTH_TOKEN`.

`N8N_ENCRYPTION_KEY` encrypts stored credentials: keep it if you recreate the stack, or saved credentials become
unreadable. Schedule Trigger nodes use `N8N_TIMEZONE`. Webhook URLs shown in the editor start with
http://localhost:5678/; other containers reach n8n at `http://n8n:5678`.

https://docs.n8n.io/
