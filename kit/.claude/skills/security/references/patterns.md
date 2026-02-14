# Security Patterns

Reusable security configurations and middleware patterns for Cloudflare Pages/Workers.

## Cloudflare Pages `_headers` File

Complete production-ready `public/_headers`:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

/api/*
  Access-Control-Allow-Methods: GET, POST, OPTIONS
  Access-Control-Allow-Headers: Content-Type
  Access-Control-Max-Age: 86400
```

## CSP Builder

Build Content-Security-Policy header by context:

```ts
function buildCSP(options: {
  analytics?: boolean;
  images?: string[];
  api?: string[];
}): string {
  const directives: string[] = [
    "default-src 'self'",
    "script-src 'self'",
    "style-src 'self' 'unsafe-inline'",
    "font-src 'self'",
    "frame-ancestors 'none'",
    "base-uri 'self'",
    "form-action 'self'",
  ];

  const imgSrc = ["'self'", "data:", "blob:"];
  const connectSrc = ["'self'"];

  if (options.analytics) {
    connectSrc.push("https://cloud.umami.is");
    directives.push("script-src 'self' https://cloud.umami.is");
  }

  if (options.images) imgSrc.push(...options.images);
  if (options.api) connectSrc.push(...options.api);

  directives.push(`img-src ${imgSrc.join(" ")}`);
  directives.push(`connect-src ${connectSrc.join(" ")}`);

  return directives.join("; ");
}
```

## CORS Middleware

Reusable CORS handler for API routes:

```ts
const ALLOWED_ORIGINS = new Set([
  "https://example.com",
  "https://www.example.com",
]);

function corsHeaders(request: Request): HeadersInit {
  const origin = request.headers.get("Origin") ?? "";
  const allowedOrigin = ALLOWED_ORIGINS.has(origin) ? origin : "";

  return {
    "Access-Control-Allow-Origin": allowedOrigin,
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Max-Age": "86400",
  };
}

function handleOptions(request: Request): Response {
  return new Response(null, {
    status: 204,
    headers: corsHeaders(request),
  });
}
```

## API Route Security Wrapper

Combines validation, CORS, and error handling:

```ts
import { z, type ZodSchema } from "zod";

type APIHandler = (request: Request, data: unknown) => Promise<Response>;

function secureEndpoint(schema: ZodSchema, handler: APIHandler) {
  return async (request: Request): Promise<Response> => {
    // CORS preflight
    if (request.method === "OPTIONS") return handleOptions(request);

    // Parse + validate
    const body = await request.json().catch(() => null);
    const result = schema.safeParse(body);

    if (!result.success) {
      return Response.json(
        {
          error: "Validation failed",
          code: "VALIDATION_ERROR",
          details: result.error.flatten().fieldErrors,
        },
        { status: 400, headers: corsHeaders(request) },
      );
    }

    const response = await handler(request, result.data);

    // Inject CORS headers
    const headers = new Headers(response.headers);
    for (const [k, v] of Object.entries(corsHeaders(request))) {
      headers.set(k, v);
    }
    return new Response(response.body, {
      status: response.status,
      headers,
    });
  };
}
```

## Environment Variable Checklist

```ts
// .dev.vars (local development — never committed)
API_KEY=dev-key-here
TURNSTILE_SECRET=0x0000000000000000000000000000000000

// wrangler.jsonc (non-secret config — committed)
{
  "vars": {
    "ENVIRONMENT": "production",
    "PUBLIC_SITE_URL": "https://example.com"
  }
}

// Production secrets (set via CLI — never in files)
// npx wrangler secret put API_KEY
// npx wrangler secret put TURNSTILE_SECRET
```

## Security Audit Checklist

Pre-launch review:

- [ ] Security headers set in `public/_headers`
- [ ] CSP configured (no `unsafe-eval`, minimal `unsafe-inline`)
- [ ] All forms use Turnstile or rate limiting
- [ ] API routes validate input with Zod
- [ ] No secrets in `wrangler.jsonc` or client code
- [ ] `.dev.vars` in `.gitignore`
- [ ] CORS origins explicitly allowlisted (no `*`)
- [ ] `innerHTML` / `set:html` / `{@html}` audited for XSS
- [ ] Database queries parameterized (no string interpolation)
- [ ] Error responses don't expose stack traces
