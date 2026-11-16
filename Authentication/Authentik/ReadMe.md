# authentik
Identity provider with OIDC / OAuth2, SAML, LDAP and a forward-auth proxy, configured through a web admin UI.
An alternative to Keycloak with a friendlier flow editor.

Requires `Databases/PostgreSQL` (the `authentik` database is created automatically on first start by the
one-shot `authentik-db-init` container). Mail goes to `Email/Mailpit` if it is running.

URL: http://localhost:8290 (HTTPS with a self-signed certificate: https://localhost:8445)<br>
Admin: `akadmin` / `Password123` (from `.env`, applied only when the database is empty)<br>
API token: `Authorization: Bearer LocalDevOnly-authentik-api-token` (`AUTHENTIK_BOOTSTRAP_TOKEN`)<br>
From containers on GroupNetwork: `http://authentik:9000`

The first start runs database migrations and takes a minute or two.

## Add an OIDC client for an ASP.NET Core app
1. Admin interface → **Applications → Applications → Create with provider** → **OAuth2/OpenID Connect**.
2. Client type *Confidential*; note the client ID and secret; redirect URI `https://localhost:5001/signin-oidc` (strict).
3. Check the **grant types** you need (authorization code, refresh token, client credentials). Providers created through the API start with none, and requests then fail with *Invalid grant_type for provider*.
4. The issuer is `http://localhost:8290/application/o/<application-slug>/`.

```csharp
builder.Services.AddAuthentication(o =>
    {
        o.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        o.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie()
    .AddOpenIdConnect(o =>
    {
        o.Authority = "http://localhost:8290/application/o/dotnet-dev/";
        o.ClientId = "dotnet-dev";
        o.ClientSecret = "<client secret>";
        o.ResponseType = "code";
        o.Scope.Add("email");
        o.RequireHttpsMetadata = false; // dev only
    });
```
Token endpoint for client credentials (service-to-service): `POST http://localhost:8290/application/o/token/` with
`grant_type=client_credentials&client_id=...&client_secret=...&scope=openid`.

## Folders
| Container path | Host folder (`Authentication/Authentik/...`) | Use |
|---|---|---|
| `/data` | `data` | Uploaded media (icons, backgrounds) and other files |
| `/certs` | `certs` | Drop certificate/key pairs here and the worker imports them |
| `/templates` | `templates` | Custom email/flow templates |

## Notes
- The server and worker listen on `0.0.0.0`. authentik's default is `[::]` only, which fails with *Address family not supported* on hosts with IPv6 disabled in containers.
- The worker doesn't mount the Docker socket, so authentik can't deploy outposts as containers automatically. Add `- /var/run/docker.sock:/var/run/docker.sock` and `user: root` to the worker if you want that.
- `AUTHENTIK_SECRET_KEY` signs sessions and tokens. Keep it stable once you have data.
- Docs: <https://docs.goauthentik.io/>
