# Floci
Open-source (MIT) AWS emulator: S3, SQS, SNS, DynamoDB, Lambda, Secrets Manager, SSM, KMS, IAM, API Gateway and
many more on one port, with no account or auth token. It is wire-compatible with LocalStack (same port, same
endpoints), so it is the default AWS emulator in this repo; `CloudEmulators/LocalStack` is the official alternative
and needs a LocalStack auth token.

Endpoint: http://localhost:4566 (from containers on GroupNetwork: `http://floci:4566`)<br>
Credentials: any non-empty values (e.g. `test` / `test`), region `us-east-1`, account `000000000000`<br>
Health: http://localhost:4566/_floci/health · Web console: http://localhost:4566/_floci/ui

## AWS CLI
```sh
export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
aws s3 mb s3://demo-bucket
aws sqs create-queue --queue-name demo-queue
aws dynamodb list-tables
```
PowerShell: `$env:AWS_ENDPOINT_URL="http://localhost:4566"` and so on.

## AWS SDK for .NET
```csharp
var credentials = new BasicAWSCredentials("test", "test");
var s3 = new AmazonS3Client(credentials, new AmazonS3Config
{
    ServiceURL = "http://localhost:4566",
    ForcePathStyle = true // bucket in the path, not the host name
});
var sqs = new AmazonSQSClient(credentials, new AmazonSQSConfig { ServiceURL = "http://localhost:4566" });
```
Recent SDK versions also pick up the `AWS_ENDPOINT_URL` environment variable, so the same code can run against AWS
in production and Floci locally.

## Persistence
`FLOCI_STORAGE_MODE=hybrid` keeps state in memory and flushes it to `CloudEmulators/Floci/data` every 5 seconds,
so buckets, queues, tables and secrets survive restarts. Use `memory` for throwaway test runs.

## Docker-backed services
Lambda, RDS, ElastiCache, ECS, MSK and the web console run real containers next to Floci through the mounted Docker
socket (for example, a Lambda function runs in a `floci-aws-<function>` container from the `public.ecr.aws/lambda/*`
runtime image). Remove the socket mount if you only need the in-process services (S3, SQS, SNS, DynamoDB, ...).

## Notes
- Returned URLs (SQS `QueueUrl`, presigned S3 URLs) use `http://localhost:4566` so apps on the host can follow them. Apps in containers should use `http://floci:4566` as their endpoint and ignore the host in returned URLs, or set `FLOCI_BASE_URL` to `http://floci:4566`.
- Docs: <https://floci.io/floci/>
