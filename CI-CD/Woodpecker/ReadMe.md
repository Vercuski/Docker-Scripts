# Woodpecker CI
Lightweight, container-native CI for the **Gitea** stack: every step is a container, pipelines are
`.woodpecker.yaml` (or `.woodpecker/*.yaml`) files in the repo.<br>
UI: http://localhost:8146 - click **Login** and sign in with your Gitea account (first time: authorize the app).<br>

Requires the **Gitea** stack with its installer completed. `woodpecker-init` logs in to Gitea with the admin account
in `.env` (`WOODPECKER_GITEA_ADMIN_USER/PASSWORD`, default `gitea_admin` / `Password123`), creates the `Woodpecker`
OAuth2 application (redirect `http://localhost:8146/authorize`) if it doesn't exist and stores its client id and
secret in the data volume. That Gitea user is also a Woodpecker admin.

- Server calls Gitea at `http://gitea:3000`; your browser is sent to `WOODPECKER_GITEA_PUBLIC_URL` (`http://localhost:3001`) to log in.
- Gitea sends push / pull-request webhooks to `http://woodpecker-server:8000` (the Gitea stack allows private addresses).
- The agent starts steps as sibling containers through the Docker socket, on **GroupNetwork**, so steps reach other
  stacks by alias (`postgresql`, `mssqldb`, `gitea`, ...). Two workflows run in parallel.
- Clone steps use the clone URL Gitea reports (its `ROOT_URL`, `http://host.docker.internal:3001`), which resolves in
  containers on Docker Desktop. On native Linux Docker, set Gitea's `GITEA_ROOT_URL` to an address step containers
  can reach, or add `host.docker.internal` to them.

Example `.woodpecker.yaml`:
```yaml
steps:
  - name: test
    image: mcr.microsoft.com/dotnet/sdk:10.0
    commands:
      - dotnet test
```

Activate a repo in the UI (**+ Add repository**), then push. Personal API token: user menu > **Personal Access Token**.
```sh
curl -H "Authorization: Bearer <token>" http://localhost:8146/api/user
```
Avatars are linked to `http://gitea:3000/...`, so they don't load in the browser (cosmetic).

https://woodpecker-ci.org/docs/intro
