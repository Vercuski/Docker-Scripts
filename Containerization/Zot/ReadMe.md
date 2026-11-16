# zot
Lightweight, OCI-native image registry (CNCF sandbox project) with a web UI, image search and built-in Trivy
vulnerability scanning. It stores any OCI artifact: images, Helm charts, SBOMs and signatures. A single small
container, unlike Harbor.

Registry and web UI: http://localhost:5002 (from containers on GroupNetwork: `zot:5000`)<br>
No login (anonymous read/write) - local development only.

## Push and pull
Docker treats `localhost` registries as trusted over plain HTTP, so no daemon configuration is needed:
```sh
docker tag myapp:latest localhost:5002/myteam/myapp:1.0
docker push localhost:5002/myteam/myapp:1.0
docker pull localhost:5002/myteam/myapp:1.0
```

## Search and vulnerability scanning
The UI lists repositories and tags with their vulnerabilities. Zot downloads the Trivy vulnerability database from
`ghcr.io` in the background after start (and every 24 h); until it has, CVE columns stay empty. The same data is
available from the GraphQL search API:
```sh
curl -G http://localhost:5002/v2/_zot/ext/search \
  --data-urlencode 'query={ImageList(repo:"myteam/myapp"){Results{RepoName Tag Size}}}'
```

## Notes
- Configuration is in `config.json` (storage, garbage collection, extensions). Restart after editing.
- Data is deduplicated across repositories (`"dedupe": true`), and untagged blobs are garbage-collected daily.
- Ports: 5000 and 5001 are used by the `DockerRegistry` stack, hence 5002.
- Docs: <https://zotregistry.dev/>
