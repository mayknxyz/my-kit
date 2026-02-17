# Workers vs Pages

## When to Use Which

| | Pages | Workers |
|---|-------|---------|
| **Best for** | Static sites, frameworks (Astro, Next) | Full server apps, APIs |
| **Deploy** | Git integration or `wrangler pages deploy` | `wrangler deploy` |
| **Functions** | File-based (`functions/` dir) or framework adapter | `export default { fetch() }` handler |
| **Static assets** | Built-in, automatic CDN | Via `assets` binding |
| **Size limit** | 128MB total deployment | 10MB Worker (paid) / 1MB (free) |

Pages Functions are Workers under the hood. Start with Pages for framework-based projects.

## wrangler.jsonc Template

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "my-project",
  "compatibility_date": "2025-09-12",
  "compatibility_flags": ["nodejs_compat"],

  // Pages static assets
  "assets": {
    "directory": "./dist"
  },

  // Non-secret config variables
  "vars": {
    "ENVIRONMENT": "production"
  },

  // Bindings (add as needed)
  "kv_namespaces": [
    { "binding": "MY_KV", "id": "abc123" }
  ],
  "d1_databases": [
    { "binding": "DB", "database_name": "my-db", "database_id": "abc123" }
  ],
  "r2_buckets": [
    { "binding": "BUCKET", "bucket_name": "my-bucket" }
  ]
}
```

### Local Secrets

Create `.dev.vars` (gitignored) for local development:

```
TURNSTILE_SECRET_KEY=0x...
API_SECRET=my-secret
```

In production, set with `wrangler secret put SECRET_NAME`.

## Astro Adapter Setup

```javascript
// astro.config.mjs
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  adapter: cloudflare({
    platformProxy: { enabled: true },  // enables local binding access
  }),
});
```

## TypeScript Bindings

```bash
npx wrangler types    # generates worker-configuration.d.ts with Env interface
```

```typescript
// src/env.d.ts
type Runtime = import('@astrojs/cloudflare').Runtime<Env>;

declare namespace App {
  interface Locals extends Runtime {
    // add custom locals here
  }
}
```

Access bindings in Astro: `Astro.locals.runtime.env.MY_KV`
Access bindings in Workers: `env.MY_KV` (from fetch handler)

## Deploy

```bash
# Workers
bunx wrangler deploy

# Pages — git integration
git push  # auto-deploys if connected

# Pages — direct upload
bunx wrangler pages deploy ./dist

# Preview locally
bunx wrangler dev
```

## Custom Headers (`public/_headers`)

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

/_astro/*
  Cache-Control: public, max-age=31536000, immutable
```

## Gotchas

- **Worker size limits**: 1MB free tier, 10MB paid. Pages: 128MB total. Bundle carefully.
- **Cold starts**: Pages Functions have near-zero cold starts. Workers may have slight delay on first request.
- **`nodejs_compat` flag**: Required for many npm packages. Always set it.
- **Bindings only in SSR**: Static/prerendered pages cannot access KV, D1, R2, or secrets at runtime.

Docs: <https://developers.cloudflare.com/workers/> | <https://developers.cloudflare.com/pages/>
