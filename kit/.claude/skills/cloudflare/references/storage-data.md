# Storage & Data Services

## Choosing the Right Service

| Service | Model | Consistency | Best For |
|---------|-------|-------------|----------|
| **KV** | Key-value | Eventually consistent | Caching, sessions, config, feature flags |
| **D1** | SQLite (relational) | Strong (single region) | Structured data, queries, JOINs |
| **R2** | Object storage (S3 API) | Strong | Files, images, audio, backups |
| **Queues** | Message queue | At-least-once delivery | Background jobs, webhooks, async processing |
| **Durable Objects** | Stateful singleton | Strong (per object) | WebSockets, counters, rate limiters, collaboration |

---

## KV (Key-Value)

Eventually consistent. Optimized for read-heavy workloads. Global replication.

```bash
bunx wrangler kv namespace create MY_KV
```

```jsonc
// wrangler.jsonc
"kv_namespaces": [{ "binding": "MY_KV", "id": "abc123" }]
```

```typescript
// Read/write
const value = await env.MY_KV.get('key');
const json = await env.MY_KV.get('key', { type: 'json' });
await env.MY_KV.put('key', 'value', { expirationTtl: 3600 });
await env.MY_KV.delete('key');

// List keys with prefix
const list = await env.MY_KV.list({ prefix: 'user:' });
```

**Gotcha**: Eventually consistent — writes may take up to 60s to propagate globally. Not suitable for real-time counters or distributed locks.

---

## D1 (SQLite)

Edge SQLite database. Strong consistency. Full SQL support.

```bash
bunx wrangler d1 create my-db
bunx wrangler d1 migrations create my-db init
bunx wrangler d1 migrations apply my-db
```

```jsonc
// wrangler.jsonc
"d1_databases": [{ "binding": "DB", "database_name": "my-db", "database_id": "abc123" }]
```

```typescript
// Always use parameterized queries (prevent SQL injection)
const user = await env.DB.prepare('SELECT * FROM users WHERE id = ?')
  .bind(userId)
  .first();

const results = await env.DB.prepare('SELECT * FROM posts WHERE author_id = ?')
  .bind(authorId)
  .all();

await env.DB.prepare('INSERT INTO users (name, email) VALUES (?, ?)')
  .bind(name, email)
  .run();

// Batch multiple statements
await env.DB.batch([
  env.DB.prepare('INSERT INTO logs (action) VALUES (?)').bind('created'),
  env.DB.prepare('UPDATE users SET updated_at = ? WHERE id = ?').bind(now, id),
]);
```

**Gotcha**: 10GB max per database. Use `batch()` for transactions. Always parameterize — never interpolate user input.

---

## R2 (Object Storage)

S3-compatible. Zero egress fees. Great for files, media, backups.

```bash
bunx wrangler r2 bucket create my-bucket
```

```jsonc
// wrangler.jsonc
"r2_buckets": [{ "binding": "BUCKET", "bucket_name": "my-bucket" }]
```

```typescript
// Upload
await env.BUCKET.put('images/photo.jpg', imageBuffer, {
  httpMetadata: { contentType: 'image/jpeg' },
});

// Download
const object = await env.BUCKET.get('images/photo.jpg');
if (object) {
  return new Response(object.body, {
    headers: { 'Content-Type': object.httpMetadata?.contentType ?? '' },
  });
}

// Delete
await env.BUCKET.delete('images/photo.jpg');

// List
const list = await env.BUCKET.list({ prefix: 'images/' });
```

**Gotcha**: No public access by default. Expose via custom domain or a Worker/Pages Function that proxies the bucket.

---

## Queues

Asynchronous message processing. At-least-once delivery.

```jsonc
// wrangler.jsonc
"queues": {
  "producers": [{ "binding": "MY_QUEUE", "queue": "my-queue" }],
  "consumers": [{ "queue": "my-queue" }]
}
```

```typescript
// Producer — send a message
await env.MY_QUEUE.send({ type: 'email', to: 'user@example.com' });

// Consumer — process messages
export default {
  async queue(batch, env) {
    for (const message of batch.messages) {
      try {
        await processMessage(message.body);
        message.ack();
      } catch {
        message.retry();
      }
    }
  },
};
```

**Use for**: Email sending, webhook forwarding, image processing, async tasks.

---

## Durable Objects

Stateful, single-instance actors with strong consistency. Each object runs in one location.

**Use for**: WebSocket chat rooms, real-time counters, distributed rate limiters, collaborative editing.

**Gotcha**: Single-threaded per instance. Use for coordination and state management, not bulk compute. Each object has its own transactional storage.

Docs: https://developers.cloudflare.com/kv/ | https://developers.cloudflare.com/d1/ | https://developers.cloudflare.com/r2/
