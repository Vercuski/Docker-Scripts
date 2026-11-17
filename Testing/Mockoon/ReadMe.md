# Mockoon
Mock APIs designed visually in the free Mockoon desktop app, served headless by the Mockoon CLI: routes with
templated responses (Faker data), rules, latency, CRUD routes over data buckets, proxying.<br>
Mock API: http://localhost:3009/api/... (from other stacks: `http://mockoon:3000`)<br>

The served file is `data/<MOCKOON_DATA_FILE>` (default `sample-api.json`); `--watch` reloads it when it changes.
Open that file in the Mockoon desktop app (*Open local environment*) to edit it visually, or save your own
environment into `data/` and set `MOCKOON_DATA_FILE`.

Sample routes:
```sh
curl http://localhost:3009/api/health
curl http://localhost:3009/api/customers/7          # random name/email (Faker); id 404 -> 404
curl http://localhost:3009/api/products             # CRUD route: GET/POST/PUT/PATCH/DELETE /api/products[/:id]
```
Admin API (request logs, reset data buckets, change state at run time):
```sh
curl -H "Authorization: Bearer local-dev-mockoon-admin-token" http://localhost:3009/mockoon-admin/logs
```
For mocks shared as code with a .NET test suite, see also the WireMock stack.

https://mockoon.com/cli/
