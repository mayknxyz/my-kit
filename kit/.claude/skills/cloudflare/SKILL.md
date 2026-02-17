---
name: cloudflare
description: >
  Cloudflare platform development — Workers, Pages, KV, D1, R2, Queues, Durable Objects,
  Turnstile, Cloudflare Images, wrangler. Use when deploying to Cloudflare, configuring
  wrangler, accessing bindings, setting up Turnstile bot protection, using KV/D1/R2
  storage, or working with Workers/Pages.
  Triggers: Cloudflare, Workers, Pages, wrangler, KV, D1, R2, Queues, Durable Objects,
  Turnstile, bindings, deploy, edge, imagedelivery.net.
---

# Cloudflare Platform

Cloudflare platform engineer. Workers-first serverless. Edge-native. Zero cold starts for Pages. See `sentry` skill for error tracking on Pages/Workers.

## Platform Decision Guide

| Need | Use | Notes |
|------|-----|-------|
| Static site | Pages (git or direct upload) | Automatic CDN, free SSL |
| Static + API routes | Pages with Functions | Your current Astro pattern |
| Full server app | Workers | Custom routing, fetch handler |
| WebSockets / state | Durable Objects | Single-instance coordination |
| Background jobs | Queues | Producer/consumer pattern |
| Caching / sessions | KV | Eventually consistent key-value |
| Relational data | D1 | SQLite at the edge |
| File storage | R2 | S3-compatible, zero egress |

## References

| Topic | File | Load When |
|-------|------|-----------|
| Workers vs Pages, wrangler, deploy | [workers-pages.md](references/workers-pages.md) | Project setup, deployment, wrangler config |
| KV, D1, R2, Queues, Durable Objects | [storage-data.md](references/storage-data.md) | Adding storage/data, choosing between services |
| Turnstile, Images, contact API pattern | [services.md](references/services.md) | Bot protection, image delivery, API patterns |

## MUST DO

- Set `compatibility_date` to a recent date in `wrangler.jsonc`
- Set `nodejs_compat` in `compatibility_flags`
- Use `.dev.vars` for local secrets (not `.env` for Cloudflare bindings)
- Type bindings with `npx wrangler types`
- Test locally with `wrangler dev` before deploying
- Choose storage by access pattern: KV for caching/sessions, D1 for relational, R2 for blobs
- Verify Turnstile tokens server-side — never trust client-only validation
- Use parameterized queries with D1 (prevent SQL injection)
- Rate limit all public API endpoints

## MUST NOT

- Use `import.meta.env` for secrets — use runtime bindings (`env.SECRET_NAME`)
- Rely on Node.js APIs without checking Workers compatibility
- Use Sharp or ImageMagick at runtime — not available on Workers
- Store secrets in `wrangler.jsonc` — use `wrangler secret put`
- Assume bindings are available in prerendered/static pages — they require SSR
- Skip rate limiting on public-facing endpoints

## CLI

```
bunx wrangler dev          # local dev server with bindings
bunx wrangler deploy       # deploy Worker
bunx wrangler pages deploy # deploy Pages (direct upload)
bunx wrangler types        # generate TypeScript types for bindings
bunx wrangler secret put   # set a secret
bunx wrangler d1           # D1 database commands
bunx wrangler r2           # R2 bucket commands
bunx wrangler kv           # KV namespace commands
```

Docs: <https://developers.cloudflare.com>
