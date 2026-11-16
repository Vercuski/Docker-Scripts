# Wiki.js 3
Markdown / visual wiki with Git storage sync, diagrams, comments and full-text search.<br>
UI: http://localhost:3003 (`admin@example.com` / `Password123`)<br>
<br>
Requires the **PostgreSQL** stack (Wiki.js 3 needs PostgreSQL 17 or newer). `wikijs-db-init` creates the `wikijs` role
and database on first start. The admin is created from `WIKIJS_ADMIN_EMAIL` / `WIKIJS_ADMIN_PASSWORD` the first time
only; change the password in the profile afterwards.<br>
<br>
Pages, uploads and settings live in the database; the `data` volume holds the cache and the local Git repository when
you enable Git storage (Administration → Storage), which is how you keep docs in a repo next to the code.

https://beta.js.wiki/docs
