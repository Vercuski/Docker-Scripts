# Wazuh (SIEM / XDR) - single node
https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html<br>
Based on the upstream `wazuh/wazuh-docker` **v4.14.8** `single-node` deployment, adapted to this repo
(GroupNetwork static IPs, bind volumes under `ROOT_VOLUME_DIR`, settings in `.env`).

| Component | Container | URL / port |
|---|---|---|
| Dashboard (web UI) | `wazuh-dashboard` | https://localhost:5603 - login `admin` / `SecretPassword` |
| Indexer (OpenSearch fork) | `wazuh-indexer` | https://localhost:9202 (`admin` / `SecretPassword`) |
| Manager (server) | `wazuh-manager` | 1514/tcp agents, 1515/tcp enrollment, 514/udp syslog, https://localhost:55000 API (`wazuh-wui`) |
| Certificate generator | `wazuh-certs` | one-shot, exits after the first run |

Containers on GroupNetwork use `wazuh.manager`, `wazuh.indexer` and `wazuh.dashboard` (these names are in the TLS certificates).

## Before the first start
Needs roughly 4 cores / 8 GB RAM free. The indexer needs a higher `vm.max_map_count`:<br>
`wsl -d docker-desktop` then `sysctl -w vm.max_map_count=262144` (Linux host: `sudo sysctl -w vm.max_map_count=262144`)

Run `CreateVolumes.bat` / `CreateVolumes.sh` so the `SIEM/Wazuh/...` folders exist, then `docker compose up -d`.

## Startup order
1. `wazuh-certs` creates the root CA and node certificates in `<ROOT_VOLUME_DIR>/docker/volumes/SIEM/Wazuh/certs`
   (downloads `wazuh-certs-tool.sh` from packages.wazuh.com, so the first run needs internet). It skips if `root-ca.pem` already exists.
2. `wazuh-indexer` starts and becomes healthy.
3. `wazuh-manager` starts, then `wazuh-dashboard`. Allow 1-2 minutes before the dashboard is usable;
   `ECONNREFUSED ...:55000` lines in the dashboard log during that window are normal.

The dashboard uses a self-signed certificate - accept the browser warning (or trust `certs/root-ca.pem`).

To regenerate certificates: `docker compose down`, delete the `certs` folder contents, `docker compose up -d`.

## Passwords
The defaults are Wazuh's documented defaults (local dev only).
- **Indexer users** (`admin`, `kibanaserver`): the indexer checks the bcrypt hashes in `config/internal_users.yml`,
  which are loaded into the security index on the *first* start only. To change one before the first start:
  1. `docker run --rm wazuh/wazuh-indexer:4.14.8 bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh -p "NewPassw0rd!"`
  2. put the hash in `config/internal_users.yml` and the plain password in `.env` (`WAZUH_INDEXER_PASSWORD` / `WAZUH_DASHBOARD_PASSWORD`).<br>
  After the first start, follow https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html#change-the-password-of-wazuh-users
  (it re-applies the file with `securityadmin.sh`), or start over with an empty `indexer/data` folder.
- **API user** (`wazuh-wui`): set by `WAZUH_API_USERNAME` / `WAZUH_API_PASSWORD` on the first start. It must be 8-64 characters
  with upper, lower, digit and one of `.*+?-`. Later changes also need `dashboard/config/wazuh.yml` updated (or that file deleted so it is regenerated).

## Adding agents
Dashboard → **Agents management → Deploy new agent** generates the install command. Use `localhost` (or the host's LAN IP)
as the server address. Windows example (PowerShell, admin):<br>
`Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.8-1.msi -OutFile $env:tmp\wazuh-agent.msi; msiexec.exe /i $env:tmp\wazuh-agent.msi /q WAZUH_MANAGER='localhost' WAZUH_AGENT_NAME='wuzahlocal'; NET START WazuhSvc`<br>
The agent version must not be newer than the manager.

Syslog sources can send to UDP 514 once a `<remote><connection>syslog</connection>...` block is added to `config/wazuh_manager.conf`
(the file is copied into the manager on start - `docker compose restart wazuh.manager` after editing).

## Notes
- Upgrading: change `WAZUH_VERSION` (all three components move together) and `WAZUH_CERT_TOOL_VERSION`, and diff the files
  in `config/` against the new upstream `single-node/config` folder. Read the Wazuh upgrade notes first.
- Can run alongside the Elastic and OpenSearch stacks - the host ports are different (9202 / 5603).
- 514/udp needs to be free on the host; change `WAZUH_SYSLOG_PORT` if something else already uses it.
