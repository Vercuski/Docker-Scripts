# Example job: a static web server in a container, published on a random host port.
#   docker exec nomad nomad job run /jobs/example.nomad.hcl   (this file is mounted at /jobs)
job "hello-web" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    network {
      port "http" {
        to = 8080
      }
    }

    task "httpd" {
      driver = "docker"

      config {
        image   = "busybox:1.37"
        command = "sh"
        args    = ["-c", "echo 'hello from nomad' > /tmp/index.html && httpd -f -p 8080 -h /tmp"]
        ports   = ["http"]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}
