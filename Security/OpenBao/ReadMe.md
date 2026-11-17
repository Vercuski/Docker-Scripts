# OpenBao
Open-source (MPL-2.0) fork of HashiCorp Vault from the Linux Foundation: same API, UI and concepts; the CLI is
`bao` instead of `vault`, and existing Vault clients work against it.<br>
UI: http://localhost:8202/ui (method **Username**, admin / Password123)<br>
API: http://localhost:8202 (from other containers: `http://openbao:8200`)<br>

Unlike the Vault stack, there is no init or unseal routine:
- **Auto-unseal**: `OPENBAO_UNSEAL_KEY` in `.env` (32 bytes, hex) unseals it on every start through the
  `static` seal. Keep that value: it encrypts the root key, so changing it makes the data unreadable.
- **Self-initialization**: on the first start with an empty data folder, `openbao.hcl` creates a full-access
  `admin` policy, the `userpass` auth method with user `admin` (password from `OPENBAO_ADMIN_PASSWORD`), and a
  KV v2 engine at `secret/`. Editing those blocks later has no effect unless you empty the data folder.

```sh
TOKEN=$(curl -s -X POST http://localhost:8202/v1/auth/userpass/login/admin -d '{"password":"Password123"}' | jq -r .auth.client_token)
curl -H "X-Vault-Token: $TOKEN" -X POST http://localhost:8202/v1/secret/data/myapi -d '{"data":{"ConnectionStrings__Default":"Server=mssqldb;..."}}'
docker exec -e BAO_TOKEN=$TOKEN openbao bao kv get secret/myapi
```
.NET: `VaultSharp` works unchanged (point it at `http://localhost:8202`, `UserPassAuthMethodInfo`).

Storage is single-node Raft (OpenBao removed the file backend). A static key next to the data is fine for local
development, not for anything shared.

https://openbao.org/docs/
