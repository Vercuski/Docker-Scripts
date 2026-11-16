# PostgreSQL + pgAdmin 4
PostgreSQL: `localhost:5432` (from other stacks: `postgresql:5432`), user `user@user.com` / `Password123`<br>
pgAdmin: http://localhost:5050 (`user@user.com` / `Password123`)<br>
<br>
The image is `pgvector/pgvector:pg18-trixie`: the official PostgreSQL 18 image with the
[pgvector](https://github.com/pgvector/pgvector) extension added, for embeddings / similarity search
(Semantic Kernel, `Pgvector.EntityFrameworkCore`). Enable it once per database:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE items (id bigserial PRIMARY KEY, content text, embedding vector(1536));
CREATE INDEX ON items USING hnsw (embedding vector_cosine_ops);
SELECT content FROM items ORDER BY embedding <=> '[...]' LIMIT 5;
```

It is a drop-in replacement for `postgres:18` (same Debian trixie base), so an existing data folder keeps working.
Changing the PostgreSQL major version on existing data requires `pg_upgrade`.
