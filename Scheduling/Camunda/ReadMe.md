# Camunda 8
BPMN/DMN process orchestration (Self-Managed, lightweight setup): model workflows as BPMN, run them on the Zeebe
engine, monitor them in Operate, work on user tasks in Tasklist, automate steps with job workers or connectors.<br>
Operate: http://localhost:8152/operate - Tasklist: http://localhost:8152/tasklist - Admin (users, roles): http://localhost:8152/admin<br>
Login `admin` / `Password123` - REST API: http://localhost:8152/v2 - gRPC (Zeebe clients): `localhost:26500`<br>

Mirrors Camunda's official lightweight Docker Compose: one **Orchestration Cluster** container (Zeebe + Operate +
Tasklist + Identity + APIs) with **file-based H2** secondary storage, and the **Connectors** runtime
(http://localhost:8153 for inbound webhooks). Settings are in `config/application.yaml`; the admin user comes from
`.env` and is created on the first start. Engine data is in the `data` volume, H2 in the `h2` volume.

`CAMUNDA_UNPROTECTED_API=true` (default) lets workers and tests call the REST/gRPC APIs without credentials, as in
Camunda's quickstart. Set it to `false` to require basic auth (then configure the connectors' credentials too).

Model with the free **Camunda Desktop Modeler** (deploy target: Self-Managed, `http://localhost:8152`, no auth).
```csharp
// The v2 REST API needs no SDK; plain HttpClient (System.Net.Http.Json)
using var http = new HttpClient { BaseAddress = new Uri("http://localhost:8152/v2/") };
var started = await http.PostAsJsonAsync("process-instances",
    new { processDefinitionId = "approval", variables = new { orderId = 42 } });
```
```sh
curl -F "resources=@approval.bpmn" http://localhost:8152/v2/deployments
curl -H "Content-Type: application/json" http://localhost:8152/v2/process-instances -d '{"processDefinitionId":"approval"}'
```
Connector secrets: add `CONNECTORS_SECRET_<NAME>` to the `camunda-connectors` environment and use
`{{secrets.<NAME>}}` in a model.

**License:** Camunda 8 Self-Managed is free for development and testing (Camunda License 1.0); production needs an
enterprise license. For an OSS-licensed engine see the Temporal stack in this category.

https://docs.camunda.io/docs/self-managed/quickstart/developer-quickstart/docker-compose/
