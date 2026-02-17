# Analytics Advanced Patterns

## Conversion Funnel Tracking

Track multi-step user journeys by chaining events:

```ts
// Step 1: User lands on pricing page
umami.track("funnel_pricing_view");

// Step 2: User clicks a plan
umami.track("funnel_plan_select", { plan: "pro", price: "29" });

// Step 3: User enters payment details
umami.track("funnel_checkout_start", { plan: "pro" });

// Step 4: Payment succeeds
umami.track("funnel_purchase_complete", { plan: "pro", value: "29" });
```

Naming convention: `funnel_<step>` keeps funnel events grouped and queryable.

### Drop-off Analysis

Compare event counts between consecutive steps. If step 2 has 1000 events and step 3 has 200, the checkout form has an 80% drop-off — investigate UX.

## A/B Test Instrumentation

Track experiment variants with custom properties:

```ts
// Assign variant (store in sessionStorage for consistency)
const variant = sessionStorage.getItem("hero_test")
  ?? (Math.random() < 0.5 ? "a" : "b");
sessionStorage.setItem("hero_test", variant);

// Track exposure
umami.track("experiment_exposure", {
  experiment: "hero_redesign",
  variant,
});

// Track conversion with variant context
umami.track("experiment_conversion", {
  experiment: "hero_redesign",
  variant,
  action: "cta_click",
});
```

Rules:

- Assign variant once per session, persist it
- Track exposure separately from conversion
- Include experiment name in every event for filtering

## Dashboard Query Patterns

### Umami API — Common Queries

```ts
// Get page views for a date range
const stats = await fetch(
  `${UMAMI_URL}/api/websites/${WEBSITE_ID}/stats?startAt=${start}&endAt=${end}`,
  { headers: { Authorization: `Bearer ${TOKEN}` } }
);

// Get event breakdown by name
const events = await fetch(
  `${UMAMI_URL}/api/websites/${WEBSITE_ID}/events?startAt=${start}&endAt=${end}`,
  { headers: { Authorization: `Bearer ${TOKEN}` } }
);

// Get metrics (top pages, referrers, browsers)
const metrics = await fetch(
  `${UMAMI_URL}/api/websites/${WEBSITE_ID}/metrics?type=url&startAt=${start}&endAt=${end}`,
  { headers: { Authorization: `Bearer ${TOKEN}` } }
);
```

### Custom Dashboards

Build with Umami's API + a simple Astro page:

- Top converting pages (page views → CTA clicks ratio)
- Traffic sources by conversion rate
- Core Web Vitals trends over time

## Error Tracking Integration

Correlate errors with user journeys:

```ts
// Track errors as analytics events
window.addEventListener("error", (event) => {
  umami.track("error_js", {
    message: event.message.slice(0, 100),
    source: event.filename,
    line: String(event.lineno),
  });
});

// Track unhandled promise rejections
window.addEventListener("unhandledrejection", (event) => {
  umami.track("error_promise", {
    reason: String(event.reason).slice(0, 100),
  });
});

// Track API errors
async function fetchWithTracking(url: string, options?: RequestInit) {
  const response = await fetch(url, options);
  if (!response.ok) {
    umami.track("error_api", {
      url,
      status: String(response.status),
    });
  }
  return response;
}
```

## Privacy Compliance Checklist

### GDPR (EU)

- [x] No cookies used (Umami is cookieless)
- [x] No PII collected (no names, emails, IPs stored)
- [x] Data stored in EU or self-hosted
- [x] Privacy policy mentions analytics tool and data collected
- [x] Respect Do-Not-Track header

### CCPA (California)

- [x] No personal information sold
- [x] Opt-out mechanism available (DNT header or JS flag)
- [x] Privacy policy discloses analytics usage

### Do-Not-Track Implementation

```ts
// Umami respects DNT by default when configured
// For custom events, check manually:
function shouldTrack(): boolean {
  if (navigator.doNotTrack === "1") return false;
  if (localStorage.getItem("analytics_optout") === "true") return false;
  return true;
}

function track(event: string, data?: Record<string, string>) {
  if (shouldTrack()) {
    umami.track(event, data);
  }
}
```

### Opt-Out UI Pattern

```ts
// Simple toggle in settings/footer
function setAnalyticsOptOut(optOut: boolean) {
  localStorage.setItem("analytics_optout", String(optOut));
}
```
