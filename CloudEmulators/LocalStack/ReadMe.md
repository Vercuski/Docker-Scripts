# LocalStack for AWS
The official LocalStack image. **Since release 2026.03 it requires an auth token to start**, and the free tier is
for non-commercial use. For a token-free AWS emulator use `CloudEmulators/Floci` (port 4566), which is
wire-compatible.

## Setup
1. Create a free account at https://app.localstack.cloud and copy your auth token (Settings → Auth Tokens).
2. Put it in `.env`: `LOCALSTACK_AUTH_TOKEN=ls-...`
3. `docker compose up -d`

Without a token the container exits with *License activation failed* (exit code 55) and Docker keeps restarting it;
run `docker compose down` until you have one.

Endpoint: http://localhost:4567 (from containers on GroupNetwork: `http://localstack:4566`)<br>
Credentials: `test` / `test`, region `us-east-1`<br>
Health: http://localhost:4567/_localstack/health

```sh
export AWS_ENDPOINT_URL=http://localhost:4567 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
aws s3 mb s3://demo-bucket
```
The .NET SDK setup is the same as in the Floci ReadMe, with port 4567.

## Notes
- Which services are available depends on the plan attached to your token.
- `LOCALSTACK_PERSISTENCE=1` saves state to `CloudEmulators/LocalStack/data` if your plan includes persistence.
- `localstack/localstack:4.14` is the last version that runs without a token, but it gets no updates or security fixes.
- The Docker socket is mounted for Lambda and other container-backed services.
- Docs: <https://docs.localstack.cloud/aws/>
