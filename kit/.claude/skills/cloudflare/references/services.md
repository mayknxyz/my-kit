# Cloudflare Services

## Turnstile (Bot Protection)

Privacy-preserving CAPTCHA alternative. Free tier available.

### Client Side

```astro
<!-- TurnstileWidget.astro -->
---
interface Props {
  siteKey: string;
}
const { siteKey } = Astro.props;
---
<div class="cf-turnstile" data-sitekey={siteKey} data-theme="auto"></div>
<script is:inline src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
```

### Server Side Verification

```typescript
async function verifyTurnstile(token: string, secretKey: string, ip?: string) {
  const response = await fetch(
    'https://challenges.cloudflare.com/turnstile/v0/siteverify',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        secret: secretKey,
        response: token,
        ...(ip && { remoteip: ip }),
      }),
    }
  );
  const result = await response.json();
  return result.success; // boolean
}
```

### Error Codes
- `missing-input-secret` — secret key not provided
- `invalid-input-secret` — secret key is wrong
- `missing-input-response` — token not provided
- `invalid-input-response` — token is invalid or expired
- `timeout-or-duplicate` — token already used or expired

Secret key comes from Cloudflare bindings: `env.TURNSTILE_SECRET_KEY`

---

## Cloudflare Images

Image optimization and delivery CDN. Variants for responsive images.

### URL Pattern

```
https://imagedelivery.net/{account_hash}/{image_id}/{variant}
```

### Variants (named presets)
- `public` — full size
- `w512`, `w384`, `w128`, `w64` — width-constrained

Configure variants in Cloudflare dashboard > Images > Variants.

### In Astro

Sharp is NOT available at Workers runtime. Choose an image service:

```javascript
// astro.config.mjs
export default defineConfig({
  image: {
    service: { entrypoint: 'astro/assets/services/compile' }, // default, build-time only
    // OR: 'astro/assets/services/passthrough' for no processing
  },
});
```

For runtime image optimization, use Cloudflare Image Resizing (paid) or pre-optimized variants via the Images API.

---

## Contact API Pattern

Repeated across your projects. Standard flow for form handling with bot protection.

### Architecture

```
POST /api/contact
  → Rate limit check (IP-based, in-memory)
  → Turnstile token verification (server-side)
  → Field validation (required fields, email format)
  → Process submission (webhook, email, database)
  → Structured response (200/400/403/429/500)
```

### Endpoint Structure

```typescript
// src/pages/api/contact.ts
import type { APIRoute } from 'astro';

export const prerender = false;

export const POST: APIRoute = async ({ request, locals, clientAddress }) => {
  // 1. Rate limit
  if (isRateLimited(clientAddress)) {
    return new Response(JSON.stringify({ error: 'Too many requests' }), {
      status: 429,
      headers: { 'Retry-After': '900' },
    });
  }

  // 2. Parse form data
  const data = await request.formData();
  const token = data.get('cf-turnstile-response') as string;

  // 3. Verify Turnstile
  const secret = locals.runtime.env.TURNSTILE_SECRET_KEY;
  if (!await verifyTurnstile(token, secret, clientAddress)) {
    return new Response(JSON.stringify({ error: 'Verification failed' }), { status: 403 });
  }

  // 4. Validate fields
  // 5. Process (webhook, store, email)
  // 6. Return success
  return new Response(JSON.stringify({ success: true }), { status: 200 });
};

// CORS preflight
export const OPTIONS: APIRoute = async ({ request }) => {
  // Validate origin against whitelist, return CORS headers
};
```

### Response Codes
- **200** — success
- **400** — validation error (missing/invalid fields)
- **403** — Turnstile verification failed
- **429** — rate limited (include `Retry-After` header)
- **500** — server error

### Optional: Webhook Forwarding

Forward validated submissions to GoHighLevel, Zapier, or other webhook:

```typescript
await fetch(env.WEBHOOK_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name, email, message }),
});
```

Docs: https://developers.cloudflare.com/turnstile/ | https://developers.cloudflare.com/images/
