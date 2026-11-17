# SeaweedFS
Fast distributed object/file store with an S3-compatible gateway (Apache 2.0). This stack runs `weed mini`: master,
volume server, filer, S3 gateway and admin UI in one container - the single-node setup meant for development.<br>
S3 API: http://localhost:8333 (from other stacks `http://seaweedfs:8333`) - access key `admin`, secret `Password123`<br>
Admin UI: http://localhost:12535 (`admin` / `Password123`) - Filer UI: http://localhost:8150 - Master: http://localhost:9333<br>

The S3 admin identity comes from `SEAWEEDFS_ACCESS_KEY` / `SEAWEEDFS_SECRET_KEY`; buckets in `SEAWEEDFS_BUCKETS`
(default `dev-bucket`) are created on start. Add users, access keys and policies in the admin UI.

```csharp
// NuGet: AWSSDK.S3
var s3 = new AmazonS3Client("admin", "Password123", new AmazonS3Config {
    ServiceURL = "http://localhost:8333", ForcePathStyle = true, AuthenticationRegion = "us-east-1" });
await s3.PutObjectAsync(new PutObjectRequest { BucketName = "dev-bucket", Key = "hello.txt", ContentBody = "hi" });
```
```sh
docker run --rm --network GroupNetwork -e AWS_ACCESS_KEY_ID=admin -e AWS_SECRET_ACCESS_KEY=Password123 \
  -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url http://seaweedfs:8333 s3 ls
```
Besides S3, the filer serves the same data over plain HTTP (`http://localhost:8150/buckets/dev-bucket/...`).

The volume server refuses new data when the disk holding the volume folder has less than 1 % free
("no volume server capacity registered yet" on upload). If you wipe the data folder, delete its hidden files too,
or the master reports a topology id mismatch.

https://github.com/seaweedfs/seaweedfs/wiki
