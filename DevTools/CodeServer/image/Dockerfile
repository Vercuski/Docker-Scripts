# code-server with the .NET SDK, git and the C# extension (Open VSX "muhammad-sammy.csharp": OmniSharp + netcoredbg -
# Microsoft's C# Dev Kit is licensed for Visual Studio products only and isn't on Open VSX).
ARG CODE_SERVER_VERSION=4.145.2
FROM codercom/code-server:${CODE_SERVER_VERSION}
ARG DOTNET_CHANNEL=10.0
USER root
# .NET into /usr/share/dotnet (dotnet-install script; covers any channel without apt repo setup)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl libicu-dev \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
 && bash /tmp/dotnet-install.sh --channel ${DOTNET_CHANNEL} --install-dir /usr/share/dotnet \
 && ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet \
 && rm /tmp/dotnet-install.sh
ENV DOTNET_ROOT=/usr/share/dotnet \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1
# Extensions are installed into /opt/code-server/extensions at build time and copied into the user's extensions
# folder (in the persisted "local" volume) on every start if missing, so they survive the volume mount.
RUN mkdir -p /opt/code-server/extensions /entrypoint.d && chown coder:coder /opt/code-server/extensions \
 && printf '%s\n' '#!/bin/sh' 'mkdir -p "$HOME/.local/share/code-server/extensions"' \
      'cp -rn /opt/code-server/extensions/. "$HOME/.local/share/code-server/extensions/"' > /entrypoint.d/10-extensions.sh \
 && chmod +x /entrypoint.d/10-extensions.sh
ENV ENTRYPOINTD=/entrypoint.d
USER coder
RUN code-server --extensions-dir /opt/code-server/extensions --install-extension muhammad-sammy.csharp \
 && code-server --extensions-dir /opt/code-server/extensions --install-extension ms-azuretools.vscode-docker \
 && ls /opt/code-server/extensions
