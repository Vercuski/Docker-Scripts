# WireMock
HTTP API mocking / service virtualization: stub endpoints, match on URL, headers and body, template responses,
inject delays and faults, record and play back a real API, and verify the requests your code made.<br>
Mocks + admin API: http://localhost:8147 (from other stacks: `http://wiremock:8080`)<br>

Stubs in `mappings/*.json` and bodies in `__files/` are loaded on start (response templating is on for all stubs).
Samples: `GET /api/hello?name=Scott`, `GET /api/orders/42`, `GET /api/flaky` (503 after 1.5 s).

```sh
curl "http://localhost:8147/api/hello?name=Scott"
curl http://localhost:8147/__admin/mappings                      # list stubs
curl -X POST http://localhost:8147/__admin/mappings/save         # persist stubs created via the API to ./mappings
curl -X POST http://localhost:8147/__admin/mappings/reset        # reload from ./mappings
curl http://localhost:8147/__admin/requests                      # request journal (verification)
```
Record a real API: `POST /__admin/recordings/start` with `{"targetBaseUrl":"https://api.example.com"}`, call the
mock, then `POST /__admin/recordings/stop`.

The .NET ports (WireMock.Net, and WireMock.Net in Testcontainers) read the same mapping format if you'd rather run
the mock inside your test process. There is no admin web UI in the open-source image.

https://wiremock.org/docs/
