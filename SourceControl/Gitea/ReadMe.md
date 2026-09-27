# Gitea + Actions runner
Self-hosted git server with GitHub-Actions-compatible CI.

1. `docker compose up -d` and open http://host.docker.internal:3001 (or http://localhost:3001).
2. Complete the one-time installer (SQLite is preselected) and create the admin account.
3. The runner registers itself automatically using `GITEA_RUNNER_REGISTRATION_TOKEN` - check
   *Site Administration > Actions > Runners*. Change the token in `.env` before first start
   (`openssl rand -hex 24`).
4. Add workflows under `.gitea/workflows/` (or `.github/workflows/`) in a repository:

```yaml
name: build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'
      - run: dotnet test
```

Clone over SSH: `git clone ssh://git@localhost:2222/<owner>/<repo>.git`

Job containers join GroupNetwork (see `runner-config.yaml`), so tests can use `mssqldb`, `postgresql`, `kafka`, etc.
The runner uses the host Docker daemon via `/var/run/docker.sock`, so jobs can see other containers on it -
fine for a personal dev box, not for untrusted code.
