# Single-node Nomad: server and client in one agent, running jobs as Docker containers on this Docker host.
# data_dir is passed on the command line (-data-dir) because it must be the same path inside this container and on
# the Docker host (the docker driver bind-mounts each allocation's folder into the job containers).
datacenter = "dc1"
bind_addr  = "0.0.0.0"

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  # Job containers publish their ports on the Docker host, which does not have this container's IP. Fingerprinting
  # the loopback interface makes Nomad publish on 127.0.0.1, i.e. localhost on the Docker host (and on Windows
  # through Docker Desktop's port forwarding).
  network_interface = "lo"
}

plugin "docker" {
  config {
    allow_privileged = false
    volumes {
      enabled = true
    }
    gc {
      image       = true
      image_delay = "1h"
    }
  }
}

ui {
  enabled = true
}
