Admin UI: http://localhost:81<br>
Owns host ports 80/443 - point proxy hosts at container names on GroupNetwork (e.g. `grafana:3000`, `seq:80`).<br>
Recent versions prompt you to create the admin account on first login (older versions: admin@example.com / changeme).

## Snippets (forward auth with Authelia)
`./snippets` is mounted read-only at `/snippets`. It holds Authelia's nginx snippets (`proxy.conf`,
`authelia-location.conf`, `authelia-authrequest.conf`) so any proxy host can require an Authelia login by pasting
three `include` lines into its **Advanced** tab. Setup and the exact Advanced config are in
`Authentication/Authelia/ReadMe.md`. Custom locations added in the Custom Locations tab bypass Authelia; define
them in the Advanced tab with the same includes instead.
