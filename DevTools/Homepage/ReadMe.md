# Homepage
A fast, static start page configured entirely in YAML - kept in git under `./config` - with one tile per stack, a
running / stopped dot from the Docker socket, and resource, search and clock widgets.<br>
UI: http://localhost:3016<br>

Standalone. Files in `./config` (mounted read-only, reloaded on change):

| File | Contents |
|---|---|
| `services.yaml` | One group per category, one tile per stack (link to the host-published UI, `container:` for the status dot). Generated from the overview table in `Claude outputs/Home.html`; edit it by hand from now on |
| `widgets.yaml` | Host CPU / memory / disk, web search, date and time |
| `bookmarks.yaml` | A few doc and tool links |
| `settings.yaml` | Title, dark theme, 3-column layout |
| `docker.yaml` | The `local` Docker host (socket mounted **read-only**) |

Homepage's own generated files (skeleton configs it creates when missing, logs) go to the `config` volume, so the
repo folder stays clean. Status dots need the stack to have a fixed `container_name` (all stacks here do).

Homepage only answers requests whose `Host` is listed in `HOMEPAGE_ALLOWED_HOSTS` (`localhost:3016` by default) -
add your hostname there if you open it any other way. It could replace the hand-maintained `Home.html`; for a
dashboard edited in the browser instead, see **DevTools/Homarr**.

Service widgets (live numbers from Grafana, Portainer, Gitea, Uptime Kuma...) can be added per tile:
https://gethomepage.dev/widgets/

https://gethomepage.dev/
