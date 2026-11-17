# RustFS
S3-compatible object storage written in Rust, Apache 2.0 licensed, with a web console. It is a drop-in for MinIO
(same S3 API, MinIO client SDKs and `mc` work) and takes MinIO's place in this repo: MinIO Community Edition has
been source-only since October 2025 (no official images or binaries) and its repository was archived in 2026.<br>
S3 API: http://localhost:9008 (from other stacks `http://rustfs:9000`) - access key `admin`, secret `Password123`<br>
Web console: http://localhost:9009/rustfs/console/ (same credentials)<br>

`rustfs-init` (AWS CLI) creates the buckets in `RUSTFS_BUCKETS` (default `dev-bucket`) if they don't exist.
The root credentials come from `.env` on every start; create further users and access keys in the console.

```csharp
// NuGet: AWSSDK.S3 (the Minio NuGet package works too)
var s3 = new AmazonS3Client("admin", "Password123", new AmazonS3Config {
    ServiceURL = "http://localhost:9008", ForcePathStyle = true, AuthenticationRegion = "us-east-1" });
await s3.PutObjectAsync(new PutObjectRequest { BucketName = "dev-bucket", Key = "hello.txt", ContentBody = "hi" });
```
```sh
docker run --rm --network GroupNetwork -e AWS_ACCESS_KEY_ID=admin -e AWS_SECRET_ACCESS_KEY=Password123 \
  -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url http://rustfs:9000 s3 ls
```
Pre-signed URLs embed the host they were signed for: sign with the address the downloader will use
(`localhost:9008` from your machine, `rustfs:9000` from other containers).

The Milvus stack still runs its own pinned MinIO image internally; that is unaffected.

https://docs.rustfs.com/
