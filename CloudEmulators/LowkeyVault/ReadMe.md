# Lowkey Vault
Community Azure Key Vault emulator (secrets, keys, certificates) by nagyesta, with a simulated managed identity
token endpoint. Microsoft has no official Key Vault emulator.

Vault URI: https://localhost:8446 (self-signed certificate; from containers on GroupNetwork: `https://lowkey-vault:8443`)<br>
Managed identity token endpoint: http://localhost:8097/metadata/identity/oauth2/token<br>
Health: http://localhost:8097/ping · Management API / Swagger: https://localhost:8446/api/swagger-ui/index.html

Lowkey Vault checks that a token is present but doesn't validate it, so any credential that produces one works.
The simplest is the built-in managed identity simulation.

## .NET (Azure.Security.KeyVault.Secrets)
Set these environment variables (App Service–style managed identity), e.g. in `launchSettings.json`:
```
IDENTITY_ENDPOINT=http://localhost:8097/metadata/identity/oauth2/token
IDENTITY_HEADER=header
```
```csharp
var options = new SecretClientOptions
{
    DisableChallengeResourceVerification = true, // the vault isn't on *.vault.azure.net
    // dev only: accept Lowkey Vault's self-signed certificate (or trust it, see below)
    Transport = new HttpClientTransport(new HttpClientHandler
    {
        ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator
    })
};
var client = new SecretClient(new Uri("https://localhost:8446"), new ManagedIdentityCredential(), options);
await client.SetSecretAsync("db-password", "Password123");
KeyVaultSecret secret = await client.GetSecretAsync("db-password");
```
The same options work for `KeyClient` and `CertificateClient`, and with `AddAzureKeyVault(...)` in configuration.
To trust the certificate instead, download it from http://localhost:8097/metadata/default-cert/lowkey-vault.p12
(password: http://localhost:8097/metadata/default-cert/password) and import it into your trusted roots.

## Persistence
The vault content is exported to `CloudEmulators/LowkeyVault/data/export.json` after every change and imported on
start. On the first start (no export yet) Lowkey Vault creates its default vaults; after that the start command adds
`--LOWKEY_VAULT_NAMES=-` so the import doesn't collide with them. Delete `export.json` to start empty.
Never put real secrets in it: the file is plain JSON.

## Vaults and host names
The default vault is `https://localhost`. Relaxed port matching is on, so it answers on the remapped host port
(8446) and the container port (8443). It also answers as `https://lowkey-vault:8443` for other containers. Lowkey
Vault creates a few more vaults (`https://primary.localhost`, `https://secondary.localhost`, ...); see them at
https://localhost:8446/management/vault.

## Notes
- 8443 is used by Nginx UI, hence 8446 on the host; 8080 (metadata) is used by CockroachDB, hence 8097.
- Extra startup options (e.g. `--LOWKEY_DEBUG_REQUEST_LOG=true`) go in `LOWKEY_VAULT_EXTRA_ARGS` in `.env`.
- Docs: <https://github.com/nagyesta/lowkey-vault>, .NET example: <https://github.com/nagyesta/lowkey-vault-example-dotnet>
