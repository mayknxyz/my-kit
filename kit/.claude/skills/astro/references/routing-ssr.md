# Routing + SSR Output Modes

## Output Mode Decision

All examples use the Cloudflare adapter (`@astrojs/cloudflare`).

| Mode | Default behavior | Opt-in/out | Best for |
|------|-----------------|------------|----------|
| `static` | All pages prerendered | — | Pure static sites, no server features |
| `hybrid` | Static by default | `prerender = false` to opt in to SSR | **Most projects** — static site with a few API routes |
| `server` | All pages SSR | `prerender = true` to opt out | Apps where most pages are dynamic |

```javascript
// astro.config.mjs
import cloudflare from '@astrojs/cloudflare';

export default defineConfig({
  output: 'hybrid',  // recommended default
  adapter: cloudflare({
    imageService: "passthrough",       // skip sharp — images served via Cloudflare CDN
    platformProxy: { enabled: true },  // local dev with bindings
  }),
});
```

> **Preview**: The Cloudflare adapter does NOT support `astro preview`. Use `bunx wrangler pages dev dist` instead. Add to `package.json`: `"preview": "bunx wrangler pages dev dist"`

Your current projects use `static` output with selective `prerender = false` on API routes only.

## Prerender Control

```astro
---
// Opt IN to SSR (in hybrid mode)
export const prerender = false;
---
```

### What requires `prerender = false`
- `Astro.request` (headers, method, body)
- `Astro.cookies` (read/write)
- Cloudflare bindings (`Astro.locals.runtime.env`)
- API endpoints that handle POST/PUT/DELETE
- Actions
- `Astro.redirect()` with dynamic logic

Pages without these features should stay prerendered for best performance.

## API Endpoints

```typescript
// src/pages/api/example.ts
import type { APIRoute } from 'astro';

export const prerender = false;

export const GET: APIRoute = async ({ locals }) => {
  // Access Cloudflare bindings
  const value = await locals.runtime.env.MY_KV.get('key');

  return new Response(JSON.stringify({ value }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
};

export const POST: APIRoute = async ({ request }) => {
  const data = await request.json();
  // process...
  return new Response(JSON.stringify({ success: true }), { status: 200 });
};
```

Docs: https://docs.astro.build/en/guides/routing/
