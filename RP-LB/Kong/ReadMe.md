# Kong
API gateway (routing, auth, rate limiting, transformations via plugins), running the open-source image in
DB-less mode.<br>
Proxy: http://localhost:8131 (from other containers: `http://kong:8000`)<br>
Admin API: http://localhost:8132<br>
Kong Manager: http://localhost:8133 (read-only in DB-less mode)<br>

Everything is declared in `kong.yml`: http://localhost:8131/web/ round-robins over the Nginx and Apache stacks
(like HAProxy) with the `rate-limiting` (600/min) and `correlation-id` (`X-Correlation-ID`) plugins. Edit it, then
reload without a restart:
```sh
curl -X POST http://localhost:8132/config -F config=@kong.yml
```
Kong 3.9 is the last open-source image (`kong`); newer versions ship only as `kong/kong-gateway`, the Enterprise
build that runs in free mode without a license.

https://developer.konghq.com/gateway/
