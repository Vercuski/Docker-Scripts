# ZAP
Dynamic application security testing: spider, passive and active scans, and an intercepting proxy.<br>
Proxy + API (always on, headless): http://localhost:8140 (from other containers: `http://zap:8140`)<br>
Desktop UI in the browser (optional): http://localhost:8139/zap/<br>

The `zap` service runs ZAP in daemon mode. Every API call needs the key from `.env` (`?apikey=` or header
`X-ZAP-API-Key`); requests without it are logged and dropped. ZAP listens on the same port number inside the
container because it proxies any request addressed to a different host:port.
```sh
K=local-dev-zap-api-key
curl "http://localhost:8140/JSON/spider/action/scan/?apikey=$K&url=http://nginx/"
curl "http://localhost:8140/JSON/alert/view/alerts/?apikey=$K&baseurl=http://nginx/"
curl "http://localhost:8140/OTHER/core/other/htmlreport/?apikey=$K" -o report.html
```
Targets on `GroupNetwork` are scanned by alias (`http://nginx`, `http://myapi:8080`). To record traffic, send it
through the proxy (`HttpClientHandler.Proxy = new WebProxy("http://localhost:8140")`); for HTTPS, trust
`zap_root_ca.cer` from the `wrk` volume.

The browser UI is a second ZAP instance and only runs when asked:
```sh
docker compose --profile ui up -d     # stop with: docker compose --profile ui stop zap-ui
```
It shares the root CA and the `wrk` folder (reports, saved sessions) but not the headless instance's history.

https://www.zaproxy.org/docs/
