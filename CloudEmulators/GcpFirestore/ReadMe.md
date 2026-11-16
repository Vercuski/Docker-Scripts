# Google Cloud Firestore emulator
Google's Firestore emulator (native mode) from the `google-cloud-cli` emulators image.

Endpoint: `localhost:8096` (gRPC and REST; from containers on GroupNetwork: `firestore-emulator:8080`)<br>
Project ID: any, e.g. `local-project` (clients must use the same one)

## .NET
Set `FIRESTORE_EMULATOR_HOST=localhost:8096`.
```csharp
var db = await new FirestoreDbBuilder
{
    ProjectId = "local-project",
    EmulatorDetection = EmulatorDetection.EmulatorOrProduction
}.BuildAsync();
await db.Collection("customers").Document("c1").SetAsync(new { Name = "Contoso", Tier = "gold" });
```

## Keeping data
Data lives in memory. To keep it, export a snapshot to the data folder:
```sh
curl -X POST http://localhost:8096/emulator/v1/projects/local-project:export \
  -H "Content-Type: application/json" \
  -d '{"database":"projects/local-project/databases/(default)","export_directory":"/data/export"}'
```
Each export creates a `firestore_export_<timestamp>` folder under `CloudEmulators/GcpFirestore/data/export`, and
on start the stack imports the newest one. Delete the folders to start empty.

The emulator also has an `--export-on-exit` option, but it doesn't run when Docker stops the container (tested with
SIGTERM and SIGINT), so this stack uses explicit exports.

## Notes
- Clear all data without restarting: `curl -X DELETE http://localhost:8096/emulator/v1/projects/local-project/databases/(default)/documents`
- 8080, the emulator's default port, is used by CockroachDB, hence 8096 on the host.
- Docs: <https://cloud.google.com/firestore/native/docs/emulator>
