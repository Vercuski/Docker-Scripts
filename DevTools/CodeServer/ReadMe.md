# code-server
VS Code in the browser (Coder's code-server), built here with the **.NET SDK** (`CODE_SERVER_DOTNET_CHANNEL`,
default 10.0), git and the C# extension.<br>
UI: http://localhost:8159 (password `Password123`)<br>

Standalone. The image is built from `image/Dockerfile` on the first `docker compose up` (rebuild after changing the
version or channel: `docker compose build`). Folders:

| Folder | In the container | Holds |
|---|---|---|
| `project` | `/home/coder/project` | your workspace (opened by default) |
| `config` | `/home/coder/.config` | code-server config |
| `local` | `/home/coder/.local` | settings, user-installed extensions, state |

C#: Microsoft's C# Dev Kit and the `ms-dotnettools.csharp` extension are licensed for Microsoft's own VS Code
builds only and aren't on Open VSX (code-server's marketplace), so the image bakes in **`muhammad-sammy.csharp`**
(the same OmniSharp language server with the open-source `netcoredbg` debugger) plus the Docker extension. They are
installed into `/opt/code-server/extensions` at build time and copied into the `local` folder on start when missing
(`/entrypoint.d/10-extensions.sh`), so the volume mount doesn't hide them. The C# extension downloads OmniSharp the
first time you open a C# project (needs internet).

The container is on GroupNetwork, so code you run inside reaches other stacks by alias
(`Host=postgresql;Username=user@user.com;Password=Password123`, `redis:6379`, `rabbitmq`...). Port **5080** is
published for an app you run inside: `dotnet run --urls http://0.0.0.0:5080` → http://localhost:5080.

The container runs as UID 1000 (`coder`), so its folders are in the `own` list of `CreateVolumes.sh`.
The IDE runs code with your access to these folders - don't expose port 8159 beyond your machine.

https://coder.com/docs/code-server
