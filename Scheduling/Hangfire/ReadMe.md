# Hangfire
Runs your own Hangfire host application (Hangfire is a .NET library, not a prebuilt image).<br>
1. Start the MSSQL stack and create the `hangfire` database (`CREATE DATABASE hangfire;`).<br>
2. `dotnet publish <YourHangfireHost>.csproj -c Release -o ./hangfire-app` (the entry assembly must be `HangfireServer.dll`, or change `command`).<br>
3. Set `DOTNET_VERSION` in `.env` to match the app's target framework.<br>
4. `docker compose up -d` - dashboard at http://localhost:5010/hangfire (if mapped with `app.UseHangfireDashboard()`).<br>
