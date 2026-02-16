# Sentry Error Reporting Patterns

## Manual Error Capture

For caught errors that are handled gracefully but still warrant tracking:

```ts
import * as Sentry from "@sentry/browser"; // or @sentry/sveltekit, @sentry/astro

try {
  await riskyOperation();
} catch (error) {
  Sentry.captureException(error, {
    tags: { feature: "payments", action: "charge" },
    extra: { userId: user.id, amount: 29.99 },
  });
  // Handle gracefully for the user
  return { error: "Payment failed. Please try again." };
}
```

## Capture Messages (Non-Error Events)

```ts
Sentry.captureMessage("User exceeded rate limit", {
  level: "warning",
  tags: { feature: "api", endpoint: "/search" },
  extra: { userId: user.id, requestCount: 150 },
});
```

Levels: `fatal`, `error`, `warning`, `info`, `debug`.

## User Context

Set after authentication, clear on logout:

```ts
// After login / session resolve
Sentry.setUser({
  id: user.id,
  email: user.email,
  username: user.name,
});

// On logout
Sentry.setUser(null);
```

Only include fields you're comfortable sending. Avoid PII unless needed.

## Tags vs Extras vs Context

| Type | Purpose | Searchable | Example |
|------|---------|-----------|---------|
| Tags | Indexed key-value pairs for filtering | Yes | `feature: "auth"`, `action: "login"` |
| Extras | Arbitrary data for debugging | No | `{ formData: {...}, requestId: "abc" }` |
| Context | Structured data grouped by category | No | `Sentry.setContext("order", { id, total })` |

```ts
Sentry.setTag("feature", "clients");

Sentry.setExtra("lastAction", "create-client");

Sentry.setContext("organization", {
  id: org.id,
  name: org.name,
  plan: org.plan,
});
```

## Breadcrumbs

Automatic breadcrumbs include: console logs, DOM clicks, XHR/fetch, navigation. Add custom breadcrumbs for business logic:

```ts
Sentry.addBreadcrumb({
  category: "auth",
  message: "User logged in",
  level: "info",
  data: { method: "email" },
});
```

## Scoped Error Context

Use `withScope` for context that applies to a single event only:

```ts
Sentry.withScope((scope) => {
  scope.setTag("transaction", "checkout");
  scope.setExtra("cart", { items: 3, total: 89.97 });
  scope.setLevel("error");
  Sentry.captureException(error);
});
```

## Performance Spans

Add custom spans within traced transactions:

```ts
const span = Sentry.startSpan(
  { name: "database.query", op: "db.query" },
  () => {
    return db.select().from(users).where(eq(users.id, id));
  }
);
```

## SvelteKit Form Action Pattern

For SvelteKit `fail()` responses that are handled but worth tracking:

```ts
// +page.server.ts
import * as Sentry from "@sentry/sveltekit";
import { fail } from "@sveltejs/kit";

export const actions = {
  create: async ({ request, locals }) => {
    try {
      // ... create resource
    } catch (error) {
      Sentry.captureException(error, {
        tags: { feature: "clients", action: "create" },
        extra: { userId: locals.user?.id },
      });
      return fail(500, { errors: { _form: ["Failed to create client"] } });
    }
  },
};
```

## Environment Detection

```ts
// Client-side
const environment = location.hostname === "yourdomain.com" ? "production" : "staging";

// Server-side (Cloudflare)
// Option 1: Detect from env var
const environment = env.BETTER_AUTH_URL?.includes("staging") ? "staging" : "production";

// Option 2: Hardcode per build (via Vite define)
const environment = __SENTRY_ENVIRONMENT__;
```

## Ignoring Known Errors

Filter out noise from errors you can't fix:

```ts
Sentry.init({
  dsn: "YOUR_DSN",
  ignoreErrors: [
    "ResizeObserver loop limit exceeded",
    "ResizeObserver loop completed with undelivered notifications",
    /Loading chunk \d+ failed/,
    "Network request failed",
  ],
  denyUrls: [
    /extensions\//i,
    /^chrome:\/\//i,
    /^moz-extension:\/\//i,
  ],
});
```

## Alerting (Sentry Dashboard)

Set up alerts in Sentry > Alerts > Create Alert:

| Alert Type | Trigger | Threshold |
|-----------|---------|-----------|
| New issue | First occurrence of a new error | Immediate |
| Spike | Error count exceeds N in time window | 10 errors in 1 hour |
| Crash rate | Error rate exceeds X% of sessions | 5% |

Free plan supports email alerts. Slack/PagerDuty integrations require paid plans.
