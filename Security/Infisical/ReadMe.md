# Infisical
Secrets manager: projects with dev/staging/prod environments, secret versioning and rollback, access control,
machine identities, a CLI and a .NET SDK.<br>
UI + API: http://localhost:8138 (admin@example.com / Password123)<br>

Requires the **PostgreSQL** and **Redis** stacks. `infisical-db-init` creates the `infisical` role and
database, the server applies its migrations on start, and `infisical-init` creates the first admin and the
organization through the instance bootstrap API. It also prints an admin **machine identity token** once:
```sh
docker logs infisical-init
```
`INFISICAL_ENCRYPTION_KEY` encrypts every stored secret: keep it if you recreate the stack.

.NET: add the `Infisical.Sdk` NuGet package and authenticate with a machine identity (Universal Auth client ID
and secret, created under Organization > Access Control > Identities), or run your app through the CLI:
`infisical run --domain http://localhost:8138 -- dotnet run`.
Email is not configured: invitations and password resets need SMTP settings (the Smtp4dev stack works).

https://infisical.com/docs/self-hosting/overview
