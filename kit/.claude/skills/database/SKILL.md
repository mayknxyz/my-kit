---
name: database
description: >
  Database patterns with D1/SQLite — schema design, migrations, parameterized queries, batch
  operations. Use when designing database schemas, writing SQL queries, creating migrations,
  or working with D1. Triggers: database, D1, SQLite, SQL, schema, migration, query, JOIN,
  index, parameterized query, batch operation.
---

# Database

Senior database engineer. D1/SQLite focus. Parameterized queries always. See `cloudflare` skill for D1 bindings and setup, `security` skill for SQL injection prevention.

## D1 Query Patterns

```ts
// Parameterized queries — ALWAYS use placeholders
const result = await env.DB.prepare(
  "SELECT * FROM posts WHERE status = ? AND author_id = ?"
).bind("published", authorId).all();

// Single row
const post = await env.DB.prepare(
  "SELECT * FROM posts WHERE slug = ?"
).bind(slug).first();

// Insert with returning
const created = await env.DB.prepare(
  "INSERT INTO posts (title, slug, content, author_id) VALUES (?, ?, ?, ?) RETURNING *"
).bind(title, slug, content, authorId).first();

// Batch operations (transactional)
const results = await env.DB.batch([
  env.DB.prepare("INSERT INTO tags (name) VALUES (?)").bind("astro"),
  env.DB.prepare("INSERT INTO tags (name) VALUES (?)").bind("svelte"),
]);
```

## Schema Design

```sql
-- Use ISO timestamps, INTEGER for booleans in SQLite
CREATE TABLE posts (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  author_id TEXT NOT NULL REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Always index foreign keys and frequently filtered columns
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_status ON posts(status);
CREATE INDEX idx_posts_slug ON posts(slug);

-- Many-to-many with junction table
CREATE TABLE post_tags (
  post_id TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);
```

## Migrations

```
migrations/
  0001_create_users.sql
  0002_create_posts.sql
  0003_add_post_tags.sql
```

```bash
# Apply migrations
bunx wrangler d1 migrations apply my-database
bunx wrangler d1 migrations apply my-database --local  # local dev
```

## Query Patterns

```sql
-- JOIN with aggregation
SELECT p.*, COUNT(c.id) as comment_count
FROM posts p
LEFT JOIN comments c ON c.post_id = p.id
WHERE p.status = 'published'
GROUP BY p.id
ORDER BY p.created_at DESC
LIMIT ? OFFSET ?;

-- Upsert
INSERT INTO settings (key, value) VALUES (?, ?)
ON CONFLICT (key) DO UPDATE SET value = excluded.value;

-- Full-text search (SQLite FTS5)
CREATE VIRTUAL TABLE posts_fts USING fts5(title, content, content=posts);
SELECT * FROM posts_fts WHERE posts_fts MATCH ?;
```

## MUST DO

- Use parameterized queries with `.bind()` — never interpolate user input
- Use migrations for all schema changes (numbered sequentially)
- Add indexes on foreign keys and frequently queried columns
- Use `TEXT` for dates in SQLite (ISO 8601 format)
- Use `env.DB.batch()` for multi-statement transactions
- Use `RETURNING *` to get inserted/updated rows

## MUST NOT

- Interpolate user input in SQL strings — always use `?` placeholders
- Skip migrations — track all schema changes
- Use `SELECT *` in production queries — select only needed columns
- Forget indexes on foreign keys and WHERE clause columns
- Use auto-increment IDs if they expose business metrics — use random IDs
- Assume D1 supports all PostgreSQL features — it's SQLite
