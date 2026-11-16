# BookStack
Documentation wiki organised as shelves → books → chapters → pages, with WYSIWYG and Markdown editors.<br>
UI: http://localhost:6875 - first login `admin@admin.com` / `password` (change it straight away).<br>
<br>
Requires the **MariaDB** stack: `bookstack-db-init` creates the `bookstack` user and database on first start.
Mail (password resets, notifications) goes to **Mailpit** (http://localhost:8025).<br>
<br>
`BOOKSTACK_APP_KEY` encrypts stored secrets: keep it unchanged once there is data.<br>
The compose file wraps the image's entrypoint to drop nginx's IPv6 `listen [::]:80` line on hosts without IPv6
(nginx otherwise fails with "Address family not supported"); on hosts with IPv6 nothing changes.

https://www.bookstackapp.com/docs/
