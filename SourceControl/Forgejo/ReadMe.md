# Forgejo + Actions runner
Community-governed fork of Gitea (Codeberg runs it), with Forgejo Actions: GitHub-Actions-compatible CI.<br>
Web UI: http://host.docker.internal:3007 (or http://localhost:3007) - **forgejo-admin** / Password123<br>
SSH: `git clone ssh://git@localhost:2223/<owner>/<repo>.git`<br>

No installer page, unlike the Gitea stack:
1. `forgejo` starts with `INSTALL_LOCK` set (SQLite database).
2. `forgejo-init` creates the administrator (or resets its password to the `.env` value) and generates a runner
   registration token. (`admin` is a reserved name in Forgejo, hence `forgejo-admin`.)
3. `forgejo-runner` registers itself with that token on its first start; check *Site Administration > Actions >
   Runners*.

Workflows go in `.forgejo/workflows/` (or `.github/workflows/`):
```yaml
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
`uses:` actions resolve from https://data.forgejo.org by default. `ubuntu-latest` maps to a Node 22 Debian image
(`runner-config.yaml`); point it at another image for a fuller toolset.

Job containers join `GroupNetwork`, so tests can use `mssqldb`, `postgresql`, `kafka`, etc. The runner uses the
host Docker daemon via `/var/run/docker.sock` - fine for a personal dev box, not for untrusted code.

https://forgejo.org/docs/latest/
