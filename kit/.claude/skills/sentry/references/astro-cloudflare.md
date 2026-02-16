# Astro on Cloudflare Pages - Sentry Setup

Packages: `@sentry/astro` + `@sentry/cloudflare`

Docs: https://docs.sentry.io/platforms/javascript/guides/cloudflare/frameworks/astro/

## Install

```bash
npx astro add @sentry/astro
bun add @sentry/cloudflare
```

## astro.config.mjs

```js
import { defineConfig } from "astro/config";
import cloudflare from "@astrojs/cloudflare";
import sentry from "@sentry/astro";

export default defineConfig({
  adapter: cloudflare(),
  integrations: [
    sentry({
      dsn: "YOUR_DSN",
      org: "your-org",
      project: "your-project",
      authToken: process.env.SENTRY_AUTH_TOKEN,
      sourceMapsUploadOptions: {
        enabled: !!process.env.SENTRY_AUTH_TOKEN,
      },
    }),
  ],
});
```

## sentry.client.config.ts

Create in project root:

```ts
import * as Sentry from "@sentry/astro";

Sentry.init({
  dsn: "YOUR_DSN",
  integrations: [Sentry.browserTracingIntegration()],
  tracesSampleRate: 0.2,
  sendDefaultPii: false,
  environment: location.hostname === "yourdomain.com" ? "production" : "staging",
});
```

## Server-Side: functions/_middleware.js

For Astro on Cloudflare, server-side Sentry uses `sentryPagesPlugin()` in a Cloudflare Pages middleware:

```js
import * as Sentry from "@sentry/cloudflare";

export const onRequest = [
  Sentry.sentryPagesPlugin((context) => ({
    dsn: "YOUR_DSN",
    tracesSampleRate: 0.2,
    sendDefaultPii: false,
  })),
];
```

This middleware intercepts all requests and wraps them in Sentry instrumentation.

## Static-Only Astro Sites

If your Astro site is fully static (no SSR, no adapter), you only need client-side tracking:

```js
// astro.config.mjs
import sentry from "@sentry/astro";

export default defineConfig({
  integrations: [
    sentry({
      dsn: "YOUR_DSN",
      org: "your-org",
      project: "your-project",
      authToken: process.env.SENTRY_AUTH_TOKEN,
    }),
  ],
});
```

Create `sentry.client.config.ts` (no server config needed):

```ts
import * as Sentry from "@sentry/astro";

Sentry.init({
  dsn: "YOUR_DSN",
  integrations: [Sentry.browserTracingIntegration()],
  tracesSampleRate: 0.2,
  environment: location.hostname === "yourdomain.com" ? "production" : "staging",
});
```

No `_middleware.js` or `@sentry/cloudflare` needed for static sites.

## wrangler.toml (SSR only)

```toml
compatibility_flags = ["nodejs_compat"]

[version_metadata]
binding = "CF_VERSION_METADATA"
```

## Requirements

- Astro >= 3.5.2
- `@sentry/astro` >= 10.8.0
- `@sentry/cloudflare` (for SSR on Cloudflare)
- `nodejs_compat` compatibility flag (SSR only)
