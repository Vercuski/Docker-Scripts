# Keycloak
OpenID Connect / OAuth 2.0 identity provider for testing ASP.NET Core authentication locally.

1. Start `Databases/PostgreSQL` and create the database:<br>
   `docker exec -it postgresql psql -U user@user.com -d postgres -c "CREATE DATABASE keycloak;"`
2. `docker compose up -d`, then open http://localhost:8280 (admin / Password123 from `.env`).
3. Create a realm (e.g. `dev`), a client, and users.

Health: http://localhost:9001/health/ready · Metrics: http://localhost:9001/metrics

ASP.NET Core (JWT bearer):
```csharp
builder.Services.AddAuthentication().AddJwtBearer(o =>
{
    o.Authority = "http://localhost:8280/realms/dev";
    o.Audience = "my-api";
    o.RequireHttpsMetadata = false; // dev only - Keycloak runs over HTTP here
});
```
Containers on GroupNetwork reach it at `http://keycloak:8080`. Tokens are issued for the URL the client used,
so use the same host in the app and in the browser when validating the issuer.
