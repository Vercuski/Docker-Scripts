# API docs: Swagger UI + Redoc
- Swagger UI: http://localhost:8113 - interactive "try it out" console; pick a spec from the dropdown
- Redoc: http://localhost:8114 - three-panel reference documentation for one spec

Spec files in `./specs` are served by both (a sample `sample-todo-api.yaml` is included). Add your own files there
and list them in `API_SPEC_URLS` (Swagger UI) / `API_SPEC_URL` (Redoc) in `.env`.<br>
<br>
The browser fetches the specs, so a running app's document works directly, e.g. an ASP.NET Core app using
`builder.Services.AddOpenApi()` / `app.MapOpenApi()` at `http://localhost:5000/openapi/v1.json`. The app must allow
CORS from `http://localhost:8113` / `http://localhost:8114`.

https://github.com/swagger-api/swagger-ui · https://redocly.com/docs/redoc
