# Atlantis
Terraform / OpenTofu pull-request automation for repositories in the **Gitea** stack: Atlantis runs `plan` when a PR
changes `.tf` files, posts the output as a PR comment, and runs `apply` when someone comments `atlantis apply`.<br>
UI (locks and jobs): http://localhost:4141

## Setup
1. Start **SourceControl/Gitea**, finish its installer, and put your Gitea admin login in this stack's `.env`
   (`ATLANTIS_GITEA_ADMIN_USER` / `ATLANTIS_GITEA_ADMIN_PASSWORD`).
2. `docker compose up -d`. `atlantis-init` creates the Gitea user `atlantis` and an API token (stored in the data
   volume as `gitea-token`) the first time; later starts just check the token.
3. In each Terraform repository:
   - *Settings → Collaborators*: add `atlantis` with **Write** access (so it can comment and set commit statuses).
   - *Settings → Webhooks → Add webhook → Gitea*: Target URL `http://atlantis:4141/events`, content type
     `application/json`, secret = `ATLANTIS_WEBHOOK_SECRET`, trigger on **Push**, **Pull request** and
     **Issue comment** events (custom events).
4. Open a pull request that changes a `.tf` file. Comment `atlantis plan` / `atlantis apply` to drive it.

Gitea must be allowed to call `atlantis` on GroupNetwork: the Gitea stack sets `webhook.ALLOWED_HOST_LIST` to
`external,private` for this. Gitea puts its public address (`localhost:3001` or `host.docker.internal:3001`) in clone
URLs, so the Atlantis entrypoint tells git to fetch those from `http://gitea:3000` instead
(`ATLANTIS_GITEA_HOST_PORT` must match Gitea's host port).

Terraform (or OpenTofu with `ATLANTIS_TF_DISTRIBUTION=opentofu`) is downloaded on demand into the data volume,
matching each project's `required_version`. Repo-level settings go in an `atlantis.yaml` at the repository root.

https://www.runatlantis.io/docs/
