# Semaphore UI
Web UI, scheduler and run history for Ansible playbooks, Terraform / OpenTofu, PowerShell and Bash scripts kept in git.<br>
UI: http://localhost:3004 (`admin` / `Password123`, created on first start)<br>
<br>
Requires the **PostgreSQL** stack (`semaphore-db-init` creates the `semaphore` role and database). Alert e-mails
go to **Mailpit**. `SEMAPHORE_ACCESS_KEY_ENCRYPTION` encrypts stored keys and passwords: keep it once data exists.<br>
<br>
Typical setup: *Key Store* (an access token for Gitea), *Repositories* (`http://gitea:3000/<owner>/<repo>.git`),
then a *Task Template* of type Terraform/OpenTofu or Ansible pointing at a folder in that repository.

https://docs.semaphoreui.com/
