# Garage
Lightweight, self-contained S3-compatible object store by Deuxfleurs (AGPL), designed for small, geo-distributed
clusters; here a single node. Also serves buckets as static websites.<br>
S3 API: http://localhost:3900 (from other stacks `http://garage:3900`) - region **`garage`**<br>
Access key `GK6d7662022c03a786ac8be692`, secret `b023faab5141afc5bac2c975f74fd1bcc0ea0bb1bacb6bb75aac2715c2b96587`<br>
Web UI (community [garage-webui](https://github.com/khairul169/garage-webui)): http://localhost:3909 - Admin API: http://localhost:3903 (Bearer `local-dev-garage-admin-token`)<br>

A new Garage node stores nothing until it has a role in the cluster layout. `garage-init` (a small Python script in
`init/` using the v2 admin API, since the Garage image has no shell) does the first-run steps once:
1. assigns the node to zone `dc1` with `GARAGE_CAPACITY_GB` and applies layout version 1;
2. imports the access key from `.env` (Garage key ids are `GK` + 24 hex characters, secrets 64 hex characters);
3. creates the buckets in `GARAGE_BUCKETS` and gives the key read/write/owner on them.
Re-running it changes nothing that already exists.

```csharp
// NuGet: AWSSDK.S3
var s3 = new AmazonS3Client("GK6d7662022c03a786ac8be692", "b023faab5141afc5bac2c975f74fd1bcc0ea0bb1bacb6bb75aac2715c2b96587",
    new AmazonS3Config { ServiceURL = "http://localhost:3900", ForcePathStyle = true, AuthenticationRegion = "garage" });
```
```sh
docker exec garage /garage status            # node, capacity, layout
docker exec garage /garage bucket list
docker exec garage /garage key create my-app  # another key (then: garage bucket allow --read --write <bucket> --key my-app)
```
Static website: `docker exec garage /garage bucket website --allow dev-bucket`, then
`curl -H "Host: dev-bucket.web.garage.localhost" http://localhost:3902/`.

Settings live in `garage.toml`; the RPC secret, admin and metrics tokens come from `.env`. Listeners bind IPv4
(`0.0.0.0`): with `[::]` Garage panics on networks without IPv6, such as GroupNetwork.
The web UI has no login of its own here (it holds the admin token) - fine for a local machine.
Prometheus metrics: `http://garage:3903/metrics` with Bearer `local-dev-garage-metrics-token`.

https://garagehq.deuxfleurs.fr/documentation/
