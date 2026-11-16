# Outline
Notion-style team knowledge base with real-time collaborative editing, Markdown shortcuts and a full API.<br>
UI: http://localhost:3002 - log in with `admin@example.com` / `Password123` (the first user becomes the admin).<br>
<br>
Requires the **PostgreSQL** stack (`outline-db-init` creates the `outline` role and database). Brings its own Redis.
Attachments are stored in the `data` volume (`FILE_STORAGE=local`). Mail goes to **Mailpit**.

## Login (Dex)
Outline has no username/password accounts: the first admin must come from an SSO provider. The stack bundles
[Dex](https://dexidp.io/) as a minimal OIDC provider (http://localhost:5556/dex) with a static user in `dex.yaml`.
The browser is sent to Dex on `localhost`, while Outline's server calls Dex's token and userinfo endpoints at
`http://outline-dex:5556` over GroupNetwork.

- **Add a user**: add an entry under `staticPasswords` in `dex.yaml` (hash with `htpasswd -bnBC 10 "" Password | tr -d ':\n'`),
  then `docker compose restart outline-dex`.
- **Use Keycloak, Authentik or Zitadel instead**: create an OIDC client with redirect URI
  `http://localhost:3002/auth/oidc.callback`, then point `OIDC_CLIENT_ID` / `OIDC_CLIENT_SECRET` and the three
  `OIDC_*_URI` values in `docker-compose.yml` at it (auth URI on `localhost`, token/userinfo URIs on the provider's
  GroupNetwork alias) and remove the `outline-dex` service.

`OUTLINE_SECRET_KEY` encrypts stored secrets: keep it unchanged once there is data.

https://docs.getoutline.com/s/hosting
