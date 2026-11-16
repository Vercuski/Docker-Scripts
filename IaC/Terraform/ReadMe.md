# Terraform CLI
Terraform CLI: `docker exec -it terraform terraform init` (this folder is mounted at `/infra`)<br>
<br>
The Gaia web UI (and its runner and MongoDB 4.4) was removed in November 2026 because the project is unmaintained.
For a UI use **IaC/Semaphore**; for pull-request driven plan/apply use **IaC/Atlantis**; for the open-source fork of
Terraform use **IaC/OpenTofu**. The old `IaC/Terraform/data` volume folder (Gaia's MongoDB) is no longer used.
