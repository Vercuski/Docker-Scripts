# HashiCorp Vault
UI: http://localhost:8200/ui

Vault runs in server mode so secrets survive restarts. That means it starts **sealed**.

First time only - initialise (single key share for local dev) and keep the output somewhere safe:<br>
`docker exec vault vault operator init -key-shares=1 -key-threshold=1`

After every container start - unseal with the unseal key:<br>
`docker exec vault vault operator unseal <unseal-key>`

Log in to the UI or CLI with the initial root token, then e.g.:<br>
`docker exec -e VAULT_TOKEN=<root-token> vault vault secrets enable -path=secret kv-v2`<br>
`docker exec -e VAULT_TOKEN=<root-token> vault vault kv put secret/myapi ConnectionStrings__Default="Server=mssqldb;..."`

.NET: use the `VaultSharp` package, or a configuration provider such as `VaultSharp.Extensions.Configuration`.
Containers on GroupNetwork reach Vault at `http://vault:8200`.

Want a throwaway in-memory Vault instead (auto-unsealed, root token `root`)? Replace `command` with
`["server", "-dev", "-dev-root-token-id=root", "-dev-listen-address=0.0.0.0:8200"]` and remove the config volume.

Linux hosts: the container runs as the non-root `vault` user - `chown` the data folder to match if it cannot write.
