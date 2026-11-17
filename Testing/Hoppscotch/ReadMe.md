# Hoppscotch
Open-source API client (a self-hosted Postman alternative): REST, GraphQL, WebSocket, SSE, Socket.IO and MQTT, with
collections, environments and team workspaces stored on your own server.<br>
App: http://localhost:3010 - Admin dashboard: http://localhost:3010/admin<br>

Requires the **PostgreSQL** stack and the **Mailpit** stack:
- `hoppscotch-db-init` creates the `hoppscotch` role and database; `hoppscotch-migrate` applies the schema migrations.
- `hoppscotch-init` completes the first-run onboarding: **email magic-link** sign-in, mail sent through `mailpit:1025`.
  The backend restarts itself once afterwards (a few seconds). After that, sign-in and SMTP settings live in the
  database; change them in the admin dashboard (*Settings*), not in `.env`.

Sign in: enter any email address, open the "Sign in to Hoppscotch" message in Mailpit (http://localhost:8025) and
click the link. The first user to open the admin dashboard becomes the instance administrator.

Requests to `localhost` from the web app are sent by your browser, so APIs on your machine work as usual (install the
Hoppscotch browser extension or use the desktop app for CORS-restricted APIs). To use the desktop app with this
server, add `http://localhost:3010` as a self-hosted instance.

`HOPPSCOTCH_DATA_ENCRYPTION_KEY` encrypts secrets in the database: keep it once data exists.

https://docs.hoppscotch.io/documentation/self-host/community-edition/getting-started
