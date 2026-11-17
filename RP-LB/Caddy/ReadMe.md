# Caddy
Web server and reverse proxy with automatic HTTPS.<br>
HTTP: http://localhost:8128<br>
HTTPS: https://localhost:8134 (certificate from Caddy's own local CA)<br>

Both sites in `Caddyfile` round-robin over the Nginx and Apache stacks (like HAProxy). Reload after editing:
```sh
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```
`local_certs` keeps Caddy from contacting Let's Encrypt: every HTTPS site gets a certificate from the local CA.
To remove the browser warning, trust the root certificate it created in the data volume
(`<ROOT_VOLUME_DIR>/docker/volumes/RP-LB/Caddy/data/caddy/pki/authorities/local/root.crt`), e.g. on Windows
`certutil -addstore -f Root root.crt` from an elevated prompt.

To serve static files, mount a folder (e.g. `./site:/srv:ro`) and add a site with `root * /srv` and `file_server`.

https://caddyserver.com/docs/
