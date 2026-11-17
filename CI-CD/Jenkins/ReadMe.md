# Jenkins
Automation server / CI (LTS line), preconfigured with Configuration as Code - no setup wizard.<br>
UI + API: http://localhost:8144 (admin / Password123)<br>

The first `docker compose up -d` builds `jenkins-plugins:<version>` from `image/` (official LTS image + the plugins in
`image/plugins.txt` + the Docker CLI). After changing `JENKINS_VERSION` or `plugins.txt`, run `docker compose up -d --build`.

- `casc/jenkins.yaml` creates the admin user (password reset from `.env` on every start), disables sign-up and
  anonymous access, sets the executor count and registers the Gitea stack (`http://gitea:3000`).
- Builds run on the controller (2 executors). The Docker socket is mounted, so Docker Pipeline steps run in sibling
  containers. Jenkins runs as root inside the container to use the socket.
- Step containers start on Docker's default network; add `args '--network GroupNetwork'` to reach other stacks by alias.

```groovy
pipeline {
  agent { docker { image 'mcr.microsoft.com/dotnet/sdk:10.0'; args '--network GroupNetwork' } }
  stages {
    stage('Build') { steps { sh 'dotnet build' } }
    stage('Test')  { steps { sh 'dotnet test --logger trx' } }
  }
}
```

API (crumb not needed with an API token; with a password, fetch `/crumbIssuer/api/json` first):
```sh
curl -u admin:Password123 http://localhost:8144/api/json
```
Gitea webhooks: `http://jenkins:8080/gitea-webhook/post` (Gitea allows private addresses in this repo).

https://www.jenkins.io/doc/
