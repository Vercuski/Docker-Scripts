# Dozzle
Real-time log viewer for every container on this Docker host, in the browser: live tail, search, split view,
multi-container streams (e.g. all of one compose project) and CPU/memory stats. It doesn't store logs; it reads
them from the Docker API, so it needs no configuration and shows every stack in this repo as soon as it starts.

Web UI: http://localhost:8103

## Notes
- The Docker socket is mounted read-only. `DOZZLE_ENABLE_ACTIONS=true` adds start/stop/restart buttons;
  `DOZZLE_ENABLE_SHELL=true` adds an in-browser shell (off by default).
- `DOZZLE_FILTER` limits what is shown, e.g. `name=defectdojo` (Docker filter syntax).
- There is no login. To add one, see Dozzle's *simple* auth provider (users file) in the docs.
- For searchable log history across restarts use Loki (`Observability/OpenTelemetry`) or Seq (`Analytics/Seq`) instead.
- Docs: <https://dozzle.dev/>
