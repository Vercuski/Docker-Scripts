# Ory Kratos + Ory Hydra
API-first identity stack:
- **Kratos** stores identities and runs the login, registration, verification, recovery, MFA and settings flows.
- **Hydra** is a certified OAuth2 / OpenID Connect server with no login screens of its own; it hands login and consent to the UI below.
- **kratos-ui** (Ory's reference self-service UI, Node.js) renders those screens. Replace it with your own UI (Razor Pages, Blazor, SPA) when you want full control.

Requires `Databases/PostgreSQL` (the `kratos` and `hydra` databases are created by the one-shot `ory-db-init`
container, then `kratos-migrate` and `hydra-migrate` apply the schemas). Mail goes to `Email/Mailpit`.

| What | URL |
|---|---|
| Self-service UI (register, login, settings) | http://127.0.0.1:4455/registration |
| Kratos public API | http://127.0.0.1:4433 |
| Kratos admin API | http://127.0.0.1:4434 |
| Hydra public (issuer, `/oauth2/auth`, `/oauth2/token`) | http://127.0.0.1:4444 |
| Hydra admin API (clients) | http://127.0.0.1:4445 |

Use **127.0.0.1**, not `localhost`, in the browser: the configs and cookies are set up for 127.0.0.1, and mixing
the two names loses the session and CSRF cookies.

There is no default user: register one at http://127.0.0.1:4455/registration. The verification code arrives in
Mailpit (http://localhost:8025).

## Register an OAuth2 client and use it from ASP.NET Core
```sh
docker exec hydra hydra create oauth2-client --endpoint http://127.0.0.1:4445 \
  --id dotnet-dev --name dotnet-dev --secret Password123 \
  --grant-type authorization_code,refresh_token,client_credentials --response-type code \
  --scope openid,offline_access,email,profile \
  --redirect-uri https://localhost:5001/signin-oidc \
  --token-endpoint-auth-method client_secret_post
```
```csharp
builder.Services.AddAuthentication(o =>
    {
        o.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        o.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie()
    .AddOpenIdConnect(o =>
    {
        o.Authority = "http://127.0.0.1:4444";
        o.ClientId = "dotnet-dev";
        o.ClientSecret = "Password123";
        o.ResponseType = "code";
        o.Scope.Add("email");
        o.RequireHttpsMetadata = false; // dev only
    });
```
Sign-in goes Hydra → UI login (Kratos) → UI consent → back to your app with an ID token whose `email` claim comes
from the Kratos identity. Add `--skip-consent` when creating a first-party client to skip the consent screen.

Machine-to-machine: `POST http://127.0.0.1:4444/oauth2/token` with
`grant_type=client_credentials&client_id=dotnet-dev&client_secret=Password123`.

## Using Kratos directly (no OAuth2)
Apps on the same site can call Kratos's public API instead: `GET http://127.0.0.1:4433/sessions/whoami` with the
browser's `ory_kratos_session` cookie returns the identity. Identities can be managed with the admin API, e.g.
`docker exec kratos kratos list identities --endpoint http://127.0.0.1:4434`.

## Files
| File | Use |
|---|---|
| `kratos/kratos.yml` | Kratos config (flows, UI URLs, methods, Hydra link) |
| `kratos/identity.schema.json` | Identity traits (email + name). Edit to add fields. |
| `hydra/hydra.yml` | Hydra config (issuer, login/consent URLs) |

Secrets, connection strings and the SMTP URL come from `.env` as environment variables.

## Notes
- Browser URLs in the two YAML files use the default ports. If you change `KRATOS_PUBLIC_PORT`, `HYDRA_PUBLIC_PORT` or `ORY_UI_PORT`, change them there too.
- The admin APIs (4434, 4445) have no authentication. They are published for local tooling only.
- `HYDRA_ADMIN_URL` for the UI must not end with `/`, or the UI calls `//admin/...` and consent fails with a 404.
- Both servers run with `--dev`, which allows plain HTTP.
- Docs: <https://www.ory.sh/docs/kratos/ory-kratos-intro>, <https://www.ory.sh/docs/hydra/>
