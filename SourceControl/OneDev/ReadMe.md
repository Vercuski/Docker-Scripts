# OneDev
Git server with built-in CI/CD, issues, pull requests, package registry and code search, in one container.<br>
Web UI: http://localhost:6610 (admin / Password123)<br>
SSH: `git clone ssh://localhost:6611/<project>`<br>

The `initial_*` variables skip the setup page on the first start (empty data folder); later changes are made in
the UI. Data, including the embedded database, lives in the `data` volume. For an external database, see
*Run as Docker Container* in the OneDev docs (the PostgreSQL stack works).

**CI**: commit a `.onedev-buildspec.yml` (or use the visual editor under *Builds*). Jobs run as containers on the
host Docker daemon through the mounted `/var/run/docker.sock`; that's fine for a personal dev box, not for
untrusted code. For jobs to reach other stacks, add `--network GroupNetwork` to the Docker executor's run options
(*Administration > Job Executors*).

https://docs.onedev.io/
