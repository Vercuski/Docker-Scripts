# ZITADEL
Identity provider (OIDC / OAuth2, SAML, passkeys, multi-tenant organizations) with a management API.
Version 4 splits the login pages into a second container (`zitadel-login`).

Requires `Databases/PostgreSQL` (the `zitadel` database is created automatically on first start by the
one-shot `zitadel-db-init` container).

Console: http://localhost:8300/ui/console<br>
Login UI: http://localhost:8301/ui/v2/login (the console redirects there)<br>
Admin: `admin@zitadel.localhost` / `Password123!` (from `.env`, applied only when the database is empty)<br>
OIDC discovery: http://localhost:8300/.well-known/openid-configuration (issuer `http://localhost:8300`)

The first start initializes the database and takes about a minute.

## How the two containers fit together
`zitadel-login` uses `network_mode: service:zitadel`: it shares the zitadel container's network, reaches the API on
`localhost:8080`, and its port 3000 is published on the zitadel service as 8301. ZITADEL's own compose example puts
Traefik in front of both instead; that isn't needed for local work.

On first start ZITADEL creates a `login-client` machine user and writes its token to the `bootstrap` folder,
which the login container reads.

## Add an OIDC client for an ASP.NET Core app
In the console: **Projects → Create** → **New application** → *Web* → *Code* (client secret) or *PKCE*.
Redirect URI `https://localhost:5001/signin-oidc`; enable *Development mode* so http and localhost URIs are allowed.

```csharp
builder.Services.AddAuthentication(o =>
    {
        o.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        o.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie()
    .AddOpenIdConnect(o =>
    {
        o.Authority = "http://localhost:8300";
        o.ClientId = "<client id>";
        o.ClientSecret = "<client secret>";
        o.ResponseType = "code";
        o.RequireHttpsMetadata = false; // dev only
    });
```

## Calling ZITADEL from other containers
ZITADEL picks the instance from the request's host name, so `http://zitadel:8080` alone answers
*unable to set instance using origin*. Containers on GroupNetwork must send `Host: localhost:8300`
(or `X-Forwarded-Host: localhost:8300`):
```sh
curl -H "Host: localhost:8300" http://zitadel:8080/.well-known/openid-configuration
```

## Notes
- `ZITADEL_MASTERKEY` encrypts secrets in the database and must stay the same once data exists.
- `ZITADEL_PORT` is part of the issuer. The login URL built from `ZITADEL_LOGIN_PORT` is saved with the instance when it is first created, so changing that port later also needs the Login V2 setting changed in the console (Default settings → Features), or an empty database.
- The login container sets `HOSTNAME=0.0.0.0`; Next.js otherwise listens on `::` only, which fails on hosts with IPv6 disabled in containers.
- Docs: <https://zitadel.com/docs>
