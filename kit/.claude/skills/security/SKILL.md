---
name: security
description: >
  Web security — CSP, XSS prevention, CORS, input validation, security headers. Use when
  configuring security headers, preventing XSS, setting up CORS, validating input, or handling
  secrets. Triggers: security, CSP, Content-Security-Policy, XSS, CORS, input validation,
  sanitize, security headers, secrets, environment variables, OWASP.
---

# Web Security

Senior security engineer. Defense in depth. Server-side validation always. See `cloudflare` skill for Turnstile/rate limiting, `api-design` skill for API security.

## Security Headers

```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' blob: data: https:; font-src 'self'; connect-src 'self' https://api.example.com; frame-ancestors 'none'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

For Cloudflare Pages, set headers in `public/_headers`:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
```

## XSS Prevention

- **Always use `textContent`** — never `innerHTML` with user data
- **Sanitize HTML** if you must render user-provided markup (use DOMPurify — client-side browser only, not Workers edge)
- **Template engines** (Astro, Svelte) auto-escape by default — don't bypass with `{@html}` or `set:html`
- **CSP** as defense-in-depth — restrict script sources, ban `eval()`

```js
// Safe
element.textContent = userInput;

// Dangerous — only with sanitized content
element.innerHTML = DOMPurify.sanitize(userMarkup);
```

## Input Sanitization

Layered strategy for Cloudflare Pages — different tools for build-time vs runtime:

| Context | Tool | Why |
|---|---|---|
| Build-time HTML (blog/CMS) | `sanitize-html` with allowlist | Full DOM available via Bun/Node |
| Runtime API routes (forms) | Zod + `stripHtml()` | No DOM on Workers edge — no library needed |

### `stripHtml()` Utility

Lightweight tag stripper for plain-text fields in API routes. No dependencies, works on Workers edge. Not a full HTML parser — sufficient for plain-text inputs where tags are never expected, not for sanitizing rich HTML (use `sanitize-html` for that):

```ts
function stripHtml(input: string): string {
  return input.replace(/<[^>]*>/g, "").trim();
}
```

Use via Zod `.transform()` (see `zod` skill for full contact form schema):

```ts
z.string().min(1).max(100).trim()
  .transform((s) => s.replace(/<[^>]*>/g, ""));
```

### Build-Time HTML Sanitization

For CMS/markdown content processed at build time (SSG), use `sanitize-html` with an allowlist:

```ts
import sanitizeHtml from "sanitize-html";

const clean = sanitizeHtml(rawHtml, {
  allowedTags: ["b", "i", "em", "strong", "a", "p", "ul", "ol", "li"],
  allowedAttributes: { a: ["href", "title"] },
  allowedSchemes: ["http", "https", "mailto"], // blocks javascript:, data: URIs
});
```

### Context-Aware Output Encoding

Encode user data based on where it appears:

| Output Context | Encoding | Example |
|---|---|---|
| HTML body | Entity-encode `<>&"'` | `&lt;script&gt;` |
| URL parameter | `encodeURIComponent()` | `?q=hello%20world` |
| JavaScript string | `JSON.stringify()` | Prevents breakout from string literals |
| HTML attribute | Entity-encode + quote attribute | `title="user&#39;s input"` |

### Cloudflare Compatibility

- **DOMPurify / isomorphic-dompurify** — broken on Workers (no DOM available)
- **sanitize-html** — works at build time (Bun/Node), broken at runtime without `nodejs_compat`
- **String-based sanitization** (`stripHtml()`, Zod transforms) — works everywhere

### Emerging Standards

- **Sanitizer API** (`Element.setHTML()`) — browser-native HTML sanitization, not yet available in all runtimes
- **Trusted Types CSP** — prevents DOM XSS by requiring typed objects for dangerous sinks

These are not production-ready yet but worth monitoring for future adoption.

## CORS Configuration

```ts
// Cloudflare Worker / API route
const corsHeaders = {
  "Access-Control-Allow-Origin": "https://example.com", // NOT "*" for credentialed requests
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
  "Access-Control-Max-Age": "86400",
};
```

- Always handle `OPTIONS` preflight requests
- Use specific origins, not `*`, when credentials are involved
- Set `Access-Control-Max-Age` to cache preflight responses

## Input Validation

- **Server-side always** — client-side validation is UX only
- **Use Zod** at API boundary (see `zod` skill)
- **Validate types, ranges, lengths, formats**
- **Parameterize SQL queries** — never interpolate (see `database` skill)

## Environment Variables

| Type | Where | Access |
|---|---|---|
| Public config | `PUBLIC_*` env vars | Safe in client code |
| Secrets | Cloudflare secrets / `.dev.vars` | Server-side only |
| API keys | Runtime bindings (`env.API_KEY`) | Never in client bundle |

## CLI Tools

```bash
# Dependency vulnerability scanning
snyk test                                # scan for known vulnerabilities
snyk monitor                             # monitor for new vulnerabilities
```

## References

| Topic | File | Load When |
|-------|------|-----------|
| Security configurations | [patterns.md](references/patterns.md) | CSP config, CORS middleware, security checklist, headers file, secrets management |

## MUST DO

- Set security headers on all responses
- Validate all input server-side with Zod or similar
- Use `textContent` for rendering user-provided text
- Use parameterized queries for all database operations
- Store secrets in environment/runtime bindings, not code
- Use HTTPS everywhere (Cloudflare handles this)
- Sanitize all user input before logging, storing, or forwarding to external services
- Use `stripHtml()` for plain-text fields in API routes (see `zod` skill for transform pattern)
- Use `sanitize-html` (build-time only) for CMS/markdown HTML content

## MUST NOT

- Trust client-side validation alone — always validate server-side
- Use `innerHTML` with unsanitized user data
- Expose API keys or secrets in client-side code
- Use `*` for CORS origin with credentialed requests
- Disable CSP for convenience — configure it properly
- Store secrets in `wrangler.jsonc`, `.env` committed to git, or client code
- Forward raw user input to webhooks, CRMs, or email templates without sanitization
- Use DOMPurify/isomorphic-dompurify in Cloudflare Workers runtime (no DOM available)
