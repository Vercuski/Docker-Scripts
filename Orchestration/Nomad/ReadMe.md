# HashiCorp Nomad
Workload orchestrator: schedules containers (and other workloads) from declarative job files. Single node here
(server + client), running jobs as containers on this Docker host.<br>
UI / API: http://localhost:4646 (no ACLs - local development only)<br>

```sh
docker exec nomad nomad job run /jobs/example.nomad.hcl     # example.nomad.hcl in this folder, mounted at /jobs
docker exec nomad nomad job status hello-web
```
With a local Nomad CLI: `NOMAD_ADDR=http://localhost:4646 nomad job run myjob.nomad.hcl`.

Job ports are published on `127.0.0.1` of the Docker host (the client fingerprints the loopback interface), so a job
port is reachable at `http://localhost:<port>` - look it up in the allocation details.<br>
<br>
`NOMAD_DATA_DIR` must be the same absolute Linux path inside the container and on the Docker host, because the docker
driver bind-mounts each allocation's folder into the job container. On Docker Desktop that path lives in its Linux VM
(not under `ROOT_VOLUME_DIR`), so job state is lost if the VM is reset.<br>
Nomad is licensed under the Business Source License 1.1 (free for development use).

https://developer.hashicorp.com/nomad/docs
