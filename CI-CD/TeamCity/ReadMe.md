# TeamCity
JetBrains CI/CD server with first-class .NET support (`dotnet` build/test/pack runners, NuGet feed, test reporting).
The free Professional license covers 100 build configurations and 3 agents.<br>
UI + REST API: http://localhost:8145<br>

## First start (once)
1. Open http://localhost:8145. The "First Start" page is skipped (`teamcity.startup.maintenance=false` selects the
   internal database), so TeamCity goes straight to the **license agreement**: review and accept it.
2. Create the administrator account (TeamCity has no setting to preset it).
3. **Agents > Unauthorized**: authorize `docker-agent`. It stays authorized across restarts (`agent` volume).

Until the license is accepted, `/healthCheck/ready` returns 503. The container healthcheck uses `/healthCheck/healthy`
so the agent can start and wait for the server.

## Agent
`jetbrains/teamcity-agent` (full image) has the .NET SDK, git and the Docker CLI. The Docker socket is mounted and the
agent runs as root, so Docker build steps and "Run in Docker container" work. Its work folder is not kept: checkouts
and caches are rebuilt after the container is recreated. Build steps reach other stacks by alias (the agent is on
GroupNetwork), e.g. a Gitea VCS root `http://gitea:3000/<owner>/<repo>.git`.

The internal database is fine for local use. For PostgreSQL, see *Administration > Database* and the TeamCity docs.

REST API with an access token (Profile > Access Tokens):
```sh
curl -H "Authorization: Bearer <token>" -H "Accept: application/json" http://localhost:8145/app/rest/server
```

https://www.jetbrains.com/help/teamcity/
