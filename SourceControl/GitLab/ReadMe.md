# GitLab CE
GitLab Community Edition (Omnibus image): repositories, merge requests, issues, wiki, CI/CD and package registry.<br>
Web UI: http://localhost:8141 - user **root**, password `GITLAB_ROOT_PASSWORD` from `.env`<br>
From other containers: `http://gitlab:8141`<br>
SSH: `git clone ssh://git@localhost:2224/<group>/<project>.git`<br>

The first start takes 3-5 minutes (the container reports healthy before the UI is ready; wait for the sign-in
page). Plan on about 3 GB of RAM. The config trims memory for a dev box: single-process Puma, 10 Sidekiq threads,
and the bundled Prometheus monitoring, container registry and KAS turned off. Change them in
`GITLAB_OMNIBUS_CONFIG`, then `docker compose up -d` (GitLab reconfigures on start).

The root password is applied only when the data folders are empty. GitLab rejects short or common passwords (and
ones containing "gitlab"); when it does, it still starts but creates **no root user**. If you can't sign in, check
`docker exec gitlab grep -A3 003_admin /var/log/gitlab/reconfigure/*.log`, then empty the three
`SourceControl/GitLab` folders and start again with a better password.

GitLab listens on 8141 inside the container too (`external_url`), so clone URLs work from the browser and from
other containers alike.

**CI**: register a runner under *Admin > CI/CD > Runners* and run `gitlab/gitlab-runner` with
`--url http://gitlab:8141` on `GroupNetwork`.

https://docs.gitlab.com/install/docker/
