# cAdvisor
CPU, memory, network and filesystem usage of every container on the Docker host.<br>
UI: http://localhost:8121 · metrics: `http://cadvisor:8080/metrics`<br>
<br>
The **Prometheus** stack scrapes it (job `cadvisor`); node-exporter in that stack covers the host itself. Useful
queries: `sum by (name) (rate(container_cpu_usage_seconds_total{name!=""}[5m]))`,
`container_memory_working_set_bytes{name!=""}`.<br>
<br>
Runs privileged with the host filesystem mounted read-only (on Docker Desktop that is the Linux VM). cAdvisor reads
Docker containers through containerd; the entrypoint picks `/run/containerd/containerd.sock` or, when dockerd manages
containerd itself, `/var/run/docker/containerd/containerd.sock`.

https://github.com/google/cadvisor
