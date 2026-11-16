# Google Cloud Spanner emulator
Google's official Spanner emulator image.

gRPC: `localhost:9011` (client libraries; from containers on GroupNetwork: `spanner-emulator:9010`)<br>
REST: `localhost:9020`

State is in memory: instances, databases and data are gone after a restart. The emulator starts empty, so create
an instance (config `emulator-config`) and a database first.

## Create an instance and database with gcloud
```sh
gcloud config configurations create emulator
gcloud config set auth/disable_credentials true
gcloud config set project local-project
gcloud config set api_endpoint_overrides/spanner http://localhost:9020/
gcloud spanner instances create test-instance --config=emulator-config --description="Test" --nodes=1
gcloud spanner databases create test-db --instance=test-instance
```

## .NET
Set `SPANNER_EMULATOR_HOST=localhost:9011`.
```csharp
var builder = new SpannerConnectionStringBuilder(
    "Data Source=projects/local-project/instances/test-instance/databases/test-db")
{
    EmulatorDetection = EmulatorDetection.EmulatorOrProduction
};
await using var connection = new SpannerConnection(builder);
```
The admin clients (`InstanceAdminClientBuilder`, `DatabaseAdminClientBuilder`) take the same `EmulatorDetection`
setting, so instances and databases can be created from code or a test fixture.

## Notes
- 9010, the emulator's default gRPC port, is used by Portainer, hence 9011 on the host.
- Docs: <https://cloud.google.com/spanner/docs/emulator>
