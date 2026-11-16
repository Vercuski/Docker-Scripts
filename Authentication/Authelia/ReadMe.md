# Authelia
Single sign-on portal that puts a login (and optional 2FA) in front of web UIs through a reverse proxy
(forward auth), plus a small OpenID Connect provider. Users live in `users_database.yml`.

Portal: https://auth.dev.localhost:9095 (self-signed certificate: accept the browser warning once)<br>
User: `admin` / `Password123` (`users_database.yml`)<br>
From containers on GroupNetwork: `https://authelia:9091`

## Why `dev.localhost` and HTTPS
Authelia refuses to run with a session cookie domain without a dot (so not `localhost`) or a portal URL that
isn't HTTPS. Browsers resolve every `*.localhost` name to your machine, so `auth.dev.localhost`,
`grafana.dev.localhost` and so on work with no DNS or hosts-file setup, and one cookie for `dev.localhost`
covers all of them. The one-shot `authelia-init` container generates a 10-year self-signed certificate for
`auth.dev.localhost`, `*.dev.localhost`, `localhost` and `authelia`, plus the OIDC signing key, in the data folder
(`Authentication/Authelia/data/certs` and `/keys`). Delete those files to regenerate them.

**Non-browser clients** (for example your ASP.NET Core app calling the token endpoint) use the OS resolver, which may
not resolve `*.localhost` subdomains. If they fail with a name-resolution error, add a hosts-file entry:
`127.0.0.1 auth.dev.localhost` (Windows: `C:\Windows\System32\drivers\etc\hosts`).

## Protect a web UI with Nginx Proxy Manager
The `RP-LB/NginxProxyManager` stack mounts Authelia's nginx snippets at `/snippets` (see its ReadMe).
1. In NPM (http://localhost:81) → **SSL Certificates → Add → Custom**: upload `data/certs/public.crt` (certificate)
   and `data/certs/private.pem` (key). Authelia's session cookie is HTTPS-only, so protected hosts must use HTTPS.
2. **Proxy Hosts → Add**: domain `mailpit.dev.localhost`, forward to `mailpit` port `8025`; SSL tab: that certificate,
   *Force SSL*; Advanced tab:
   ```nginx
   include /snippets/authelia-location.conf;

   location / {
       include /snippets/proxy.conf;
       include /snippets/authelia-authrequest.conf;
       proxy_pass $forward_scheme://$server:$port;
   }
   ```
3. Open https://mailpit.dev.localhost: you are sent to the portal, and after login back to Mailpit. The app receives
   `Remote-User`, `Remote-Groups`, `Remote-Email` and `Remote-Name` headers.

Which hosts need which level is set in `access_control` in `configuration.yml`. The default here is
`one_factor` for `*.dev.localhost` and deny for everything else. Use `two_factor` to require TOTP or WebAuthn;
enrollment codes are sent to Mailpit.

## OpenID Connect
Issuer `https://auth.dev.localhost:9095`. A client `dotnet-dev` (secret `Password123`, redirect
`https://localhost:5001/signin-oidc`) is defined in `configuration.yml`; copy it for more clients and generate
secret digests with `docker exec authelia authelia crypto hash generate pbkdf2 --variant sha512 --password 'secret'`.

```csharp
builder.Services.AddAuthentication(o =>
    {
        o.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        o.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie()
    .AddOpenIdConnect(o =>
    {
        o.Authority = "https://auth.dev.localhost:9095";
        o.ClientId = "dotnet-dev";
        o.ClientSecret = "Password123";
        o.ResponseType = "code";
        o.Scope.Add("email");
        o.Scope.Add("groups");
        o.GetClaimsFromUserInfoEndpoint = true; // Authelia puts profile/email/groups in userinfo, not the ID token
        // dev only: trust the self-signed certificate (or import data/certs/public.crt into your trusted roots)
        o.BackchannelHttpHandler = new HttpClientHandler
        {
            ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator
        };
    });
```
Authelia shows a consent screen on first sign-in to each client.

## Files
| File | Use |
|---|---|
| `configuration.yml` | Main config, loaded with Authelia's template filter (values from `.env` via environment variables). Template expressions are evaluated even in comments. |
| `users_database.yml` | Users. Authelia reloads it when it changes and writes to it when a user resets a password. |
| data folder | SQLite database, TLS certificate, OIDC key |

## Notes
- Secrets are set with Authelia's `AUTHELIA_*` environment variables from `.env`. `AUTHELIA_STORAGE_ENCRYPTION_KEY` can't change once the database exists.
- Docs: <https://www.authelia.com/configuration/prologue/introduction/>
