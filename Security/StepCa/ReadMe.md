# step-ca
Smallstep's private certificate authority: real HTTPS certificates for local services, issued over ACME (like
Let's Encrypt) or with the `step` CLI.<br>
CA API: https://localhost:9003 (from other containers: `https://step-ca:9000`)<br>
ACME directory: `https://step-ca:9000/acme/acme/directory`<br>

The first start (empty data folder) creates a root and an intermediate CA named `STEPCA_NAME`, a password
provisioner (`admin`, password `STEPCA_PASSWORD`) and an ACME provisioner (`acme`). Certificates last 24 hours
by default, so use ACME clients that renew automatically.

1. Trust the root certificate (once):
   ```powershell
   docker cp step-ca:/home/step/certs/root_ca.crt .
   certutil -addstore -f Root root_ca.crt     # elevated prompt; Linux: copy to /usr/local/share/ca-certificates + update-ca-certificates
   ```
2. Issue certificates:
   - **ACME** (http-01): the client must be reachable as the requested name on port 80 over `GroupNetwork`,
     e.g. Caddy with `acme_ca https://step-ca:9000/acme/acme/directory` and `acme_ca_root /path/root_ca.crt`.
   - **step CLI**: `docker exec -it step-ca step ca certificate myapi.local myapi.crt myapi.key` (asks for the
     provisioner password).

https://smallstep.com/docs/step-ca/
