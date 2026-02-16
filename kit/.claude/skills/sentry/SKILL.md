---
name: sentry
description: >
  Sentry error tracking and performance monitoring for Cloudflare Pages sites.
  Covers SvelteKit, Astro, and vanilla (HTML/JS) projects. Use when integrating
  Sentry, configuring error tracking, adding performance monitoring, or debugging
  production errors.
  Triggers: Sentry, error tracking, error monitoring, captureException, captureMessage,
  source maps, performance monitoring, tracing, breadcrumbs, handleErrorWithSentry,
  initCloudflareSentryHandle, sentryPagesPlugin.
---

# Sentry

Error tracking and performance monitoring for Cloudflare Pages. Framework-aware setup. See `cloudflare` skill for Workers/Pages platform, `security` skill for CSP headers.

## SDK Decision Guide

| Stack | Package(s) | Server Init |
|-------|-----------|-------------|
| SvelteKit + Cloudflare | `@sentry/sveltekit` | `initCloudflareSentryHandle()` in hooks |
| Astro + Cloudflare | `@sentry/astro` + `@sentry/cloudflare` | `sentryPagesPlugin()` in `_middleware.js` |
| Vanilla (static HTML/JS) | `@sentry/browser` | N/A (client-only) |
| Cloudflare Worker (no framework) | `@sentry/cloudflare` | `withSentry()` in fetch handler |

## Free Plan Limits

| Resource | Limit |
|----------|-------|
| Errors | 5,000/month |
| Performance units | 10,000/month |
| Replays | 50/month |
| Data retention | 30 days |
| Team members | 1 |

Tune `tracesSampleRate` to stay within limits:
- **Low traffic** (<500 daily transactions): `0.5` - `1.0`
- **Medium traffic** (500-2,000): `0.1` - `0.3`
- **High traffic** (2,000+): `0.05` - `0.1`

## Vanilla (Static HTML/JS) Setup

For static sites without a framework, use `@sentry/browser` directly:

```html
<script
  src="https://browser.sentry-cdn.com/9.x.x/bundle.tracing.min.js"
  crossorigin="anonymous"
></script>
<script>
  Sentry.init({
    dsn: "YOUR_DSN",
    tracesSampleRate: 0.2,
    environment: location.hostname === "example.com" ? "production" : "staging",
  });
</script>
```

Or via npm:

```ts
import * as Sentry from "@sentry/browser";

Sentry.init({
  dsn: "YOUR_DSN",
  integrations: [Sentry.browserTracingIntegration()],
  tracesSampleRate: 0.2,
});
```

## Wrangler Config (all frameworks)

Required for server-side Sentry on Cloudflare:

```toml
compatibility_flags = ["nodejs_compat"]

[version_metadata]
binding = "CF_VERSION_METADATA"
```

## Source Maps

Upload source maps for readable stack traces. Add `SENTRY_AUTH_TOKEN` as a Cloudflare Pages build-time environment variable (Settings > Environment variables). The Vite/Astro plugin reads it during build and skips upload silently when absent.

Create token at: Sentry > Settings > Developer Settings > Auth Tokens (scope: `org:ci`).

## References

| Topic | File | Load When |
|-------|------|-----------|
| SvelteKit + Cloudflare setup | [sveltekit-cloudflare.md](references/sveltekit-cloudflare.md) | SvelteKit hooks, vite plugin, svelte.config |
| Astro + Cloudflare setup | [astro-cloudflare.md](references/astro-cloudflare.md) | Astro integration, middleware, sentry config files |
| Error reporting patterns | [patterns.md](references/patterns.md) | Manual capture, user context, breadcrumbs, performance spans, alerting |

## MUST DO

- Choose the correct SDK package for your stack (see decision guide)
- Set `tracesSampleRate` based on traffic and plan limits
- Set `environment` tag to differentiate production vs staging
- Set user context (`Sentry.setUser()`) after authentication resolves
- Clear user context on logout (`Sentry.setUser(null)`)
- Add `version_metadata` binding in `wrangler.toml` for release tracking
- Add `nodejs_compat` to `compatibility_flags` (required for server-side SDK)
- Upload source maps via `SENTRY_AUTH_TOKEN` for readable stack traces
- Use structured tags and extras in `captureException()` for filtering

## MUST NOT

- Use Node.js server init (`Sentry.init()`) on Cloudflare server side - use the Cloudflare-specific handles
- Set `tracesSampleRate: 1.0` in production on free plan (exhausts quota in days)
- Include PII in error extras without explicit consent (`sendDefaultPii: false`)
- Commit `SENTRY_AUTH_TOKEN` to git (build-time secret only)
- Put DSN in secrets manager (it's public - embedded in client JS)
- Log sensitive data (passwords, tokens, API keys) in error context
- Skip environment tags - always differentiate production vs staging

## CLI

```bash
# SvelteKit
bun add @sentry/sveltekit

# Astro
npx astro add @sentry/astro && bun add @sentry/cloudflare

# Vanilla
bun add @sentry/browser
```

Docs: https://docs.sentry.io/platforms/javascript/
