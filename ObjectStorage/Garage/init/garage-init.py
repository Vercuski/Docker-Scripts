"""One-shot setup for the single-node Garage stack, through Garage's v2 admin API (the Garage image has no shell).
Idempotent: assigns the node a layout role once, imports the access key from .env and creates the buckets."""
import json, os, sys, time, urllib.error, urllib.request

API = "http://garage:3903"
TOKEN = os.environ["GARAGE_ADMIN_TOKEN"]


def call(method, path, body=None, ok404=False):
    req = urllib.request.Request(API + path, method=method,
                                 data=None if body is None else json.dumps(body).encode(),
                                 headers={"Authorization": "Bearer " + TOKEN, "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            data = r.read()
            return json.loads(data) if data else {}
    except urllib.error.HTTPError as e:
        if ok404 and e.code in (400, 404):
            return None
        sys.exit(f"{method} {path}: HTTP {e.code} {e.read().decode()}")


for _ in range(60):
    try:
        status = call("GET", "/v2/GetClusterStatus")
        break
    except (urllib.error.URLError, ConnectionError):
        time.sleep(2)
else:
    sys.exit("garage admin API not reachable")

node = status["nodes"][0]
if not node.get("role"):
    capacity = int(os.environ["CAPACITY_GB"]) * 1000 ** 3
    call("POST", "/v2/UpdateClusterLayout",
         {"roles": [{"id": node["id"], "zone": "dc1", "capacity": capacity, "tags": ["docker"]}]})
    version = call("GET", "/v2/GetClusterLayout")["version"] + 1
    call("POST", "/v2/ApplyClusterLayout", {"version": version})
    print(f"layout v{version}: node {node['id'][:16]} in zone dc1, {os.environ['CAPACITY_GB']} GB")
else:
    print("layout already assigned")

key_id, secret = os.environ["ACCESS_KEY_ID"], os.environ["SECRET_KEY"]
if call("GET", f"/v2/GetKeyInfo?id={key_id}", ok404=True) is None:
    call("POST", "/v2/ImportKey", {"accessKeyId": key_id, "secretAccessKey": secret, "name": "dev"})
    print(f"imported access key {key_id}")
else:
    print(f"access key {key_id} exists")

for name in filter(None, (b.strip() for b in os.environ["BUCKETS"].split(","))):
    bucket = call("GET", f"/v2/GetBucketInfo?globalAlias={name}", ok404=True)
    if bucket is None:
        bucket = call("POST", "/v2/CreateBucket", {"globalAlias": name})
        print(f"created bucket {name}")
    call("POST", "/v2/AllowBucketKey", {"bucketId": bucket["id"], "accessKeyId": key_id,
                                        "permissions": {"read": True, "write": True, "owner": True}})
print("garage-init done")
