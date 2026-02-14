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

### Presigned URLs (Browser Uploads)

For client-side uploads directly to R2, generate presigned URLs server-side using the S3 API:

```typescript
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
  credentials: { accessKeyId, secretAccessKey },
});

const url = await getSignedUrl(
  client,
  new PutObjectCommand({ Bucket: bucketName, Key: key, ContentType: type, ContentLength: size }),
  { expiresIn: 300 }
);
```

### R2 CORS Configuration (Required for Browser Uploads)

**Critical**: R2 buckets have NO CORS rules by default. Browser uploads via presigned URLs will fail with a CORS preflight error unless you configure CORS on the bucket.

```bash
# Check current CORS rules
bunx wrangler r2 bucket cors list my-bucket

# Set CORS rules from a JSON file
bunx wrangler r2 bucket cors set my-bucket --file r2-cors.json --force
```

```json
{
  "rules": [
    {
      "allowed": {
        "origins": ["https://example.com", "http://localhost:5173"],
        "methods": ["GET", "PUT", "HEAD"],
        "headers": ["content-type", "content-length"]
      },
      "expose": ["ETag"],
      "maxAge": 3600
    }
  ]
}
```

**Checklist for R2 browser uploads**:
1. R2 bucket exists (`wrangler r2 bucket create`)
2. R2 API credentials set (account ID, access key, secret key)
3. CORS rules configured on bucket (`wrangler r2 bucket cors set`)
4. Presigned URL generated server-side with correct bucket name
5. Client sends PUT to presigned URL with matching Content-Type/Content-Length
6. CSP `img-src` includes `blob:` if using `URL.createObjectURL()` for previews

### Serving R2 Files (Authenticated Proxy)

R2 buckets are private by default. Serve files through an API route:

```typescript
// src/routes/api/files/[...path]/+server.ts
import { GetObjectCommand } from '@aws-sdk/client-s3';

export const GET: RequestHandler = async ({ params, platform, locals }) => {
  if (!locals.user) throw error(401, 'Unauthorized');

  const client = createR2Client(accountId, accessKeyId, secretAccessKey);
  const response = await client.send(
    new GetObjectCommand({ Bucket: bucketName, Key: params.path })
  );

  return new Response(response.Body as ReadableStream, {
    headers: {
      'Content-Type': response.ContentType ?? 'application/octet-stream',
      'Cache-Control': 'private, max-age=3600',
    },
  });
};
```

Store the R2 key in the database, render as `/api/files/${r2Key}` in templates.

### Local Dev Gotcha: Binding vs S3 API

**Critical**: `wrangler pages dev` emulates R2 bindings locally (miniflare). If uploads use presigned URLs (S3 API hitting the remote bucket), the local `FILES_BUCKET` binding won't have those files. Use the S3 API (`GetObjectCommand`) for serving too, so both upload and download hit the same remote bucket. The binding approach (`env.BUCKET.get()`) only works when both reads and writes use the binding.

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
