# SvelteKit on Cloudflare Pages - Sentry Setup

Package: `@sentry/sveltekit` (handles both client and server)

Docs: <https://docs.sentry.io/platforms/javascript/guides/cloudflare/frameworks/sveltekit/>

## Install

```bash
bun add @sentry/sveltekit
```

## vite.config.ts

`sentrySvelteKit()` must come BEFORE `sveltekit()`:

```ts
import { sveltekit } from "@sveltejs/kit/vite";
import { sentrySvelteKit } from "@sentry/sveltekit";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    sentrySvelteKit({
      sourceMapsUploadOptions: {
        org: "your-org",
        project: "your-project",
        authToken: process.env.SENTRY_AUTH_TOKEN,
      },
    }),
    tailwindcss(),
    sveltekit(),
  ],
});
```

## svelte.config.js

Enable experimental instrumentation and tracing:

```js
const config = {
  kit: {
    experimental: {
      instrumentation: {
        server: true,
      },
      tracing: {
        server: true,
      },
    },
  },
};
```

## src/hooks.client.ts

Client-side Sentry init. DSN is hardcoded (it's public):

```ts
import * as Sentry from "@sentry/sveltekit";

Sentry.init({
  dsn: "YOUR_DSN",
  tracesSampleRate: 0.2,
  sendDefaultPii: false,
  environment: location.hostname === "yourdomain.com" ? "production" : "staging",
});

const myErrorHandler = ({ error, event }: { error: unknown; event: unknown }) => {
  console.error("Client error:", error, event);
};

export const handleError = Sentry.handleErrorWithSentry(myErrorHandler);
```

## src/hooks.server.ts

Use `initCloudflareSentryHandle()` (NOT `Sentry.init()`) as the FIRST handle in `sequence()`:

```ts
import {
  initCloudflareSentryHandle,
  sentryHandle,
  handleErrorWithSentry,
} from "@sentry/sveltekit";
import * as Sentry from "@sentry/sveltekit";
import { sequence } from "@sveltejs/kit/hooks";

export const handle = sequence(
  initCloudflareSentryHandle({
    dsn: "YOUR_DSN",
    tracesSampleRate: 0.2,
    sendDefaultPii: false,
  }),
  sentryHandle(),
  // ... your other handles (auth, security headers, etc.)
);

const myErrorHandler = ({ error, event }: { error: unknown; event: unknown }) => {
  console.error("Server error:", error, event);
};

export const handleError = handleErrorWithSentry(myErrorHandler);
```

### Handle Order

1. `initCloudflareSentryHandle()` - Creates Sentry scope for the request
2. `sentryHandle()` - Adds request tracing and breadcrumbs
3. Your handles (security headers, auth, etc.)

### User Context in Auth Handle

Set user context after session resolution so all Sentry events include user info:

```ts
const authHandle: Handle = async ({ event, resolve }) => {
  // ... resolve session ...

  if (event.locals.user) {
    Sentry.setUser({
      id: event.locals.user.id,
      email: event.locals.user.email,
    });
  } else {
    Sentry.setUser(null);
  }

  return resolve(event);
};
```

## Client User Context (Layout)

In root `+layout.svelte`, sync user context:

```svelte
<script lang="ts">
  import * as Sentry from "@sentry/sveltekit";
  import { page } from "$app/stores";

  $effect(() => {
    const user = $page.data.user;
    if (user) {
      Sentry.setUser({ id: user.id, email: user.email });
    } else {
      Sentry.setUser(null);
    }
  });
</script>
```

## wrangler.toml

```toml
compatibility_flags = ["nodejs_compat"]

[version_metadata]
binding = "CF_VERSION_METADATA"
```

## Requirements

- SvelteKit >= 2.31.0
- `@sentry/sveltekit` >= 10.8.0
- `nodejs_compat` compatibility flag
