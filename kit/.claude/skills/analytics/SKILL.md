---
name: analytics
description: >
  Privacy-first analytics with Umami, event tracking, and Core Web Vitals reporting. Use when
  setting up analytics, event tracking, UTM parameters, or performance monitoring. Triggers:
  analytics, Umami, event tracking, web-vitals, UTM parameters, page views, scroll depth,
  privacy-first analytics.
---

# Analytics

Senior analytics engineer. Privacy-first. Umami preferred. No cookies. See `performance` skill for Core Web Vitals optimization, `seo` skill for search performance.

## Umami Setup

```html
<!-- Self-hosted Umami — no cookies, GDPR-compliant by default -->
<script
  defer
  src="https://analytics.yourdomain.com/script.js"
  data-website-id="your-website-id"
></script>
```

- Self-host on Cloudflare Workers or VPS
- No cookie banner needed — tracks without cookies
- Lightweight (~2KB gzipped)
- Respects `Do-Not-Track` header

## Event Tracking

```ts
// Umami event tracking API
umami.track("form_submit", { form: "contact", source: "homepage" });
umami.track("cta_click", { label: "get-started", position: "hero" });
umami.track("scroll_depth", { depth: "50" });
```

### Event Naming Convention

```
<action>_<object>

form_submit        — form submissions
cta_click          — call-to-action clicks
link_click         — outbound/important link clicks
scroll_depth       — scroll milestones (25%, 50%, 75%, 100%)
page_view          — automatic (no manual tracking needed)
error_shown        — error states displayed to user
```

## Core Web Vitals Reporting

```ts
import { onCLS, onINP, onLCP } from "web-vitals";

function sendToAnalytics(metric: { name: string; value: number }) {
  umami.track("web_vital", {
    metric: metric.name,
    value: Math.round(metric.value),
  });
}

onCLS(sendToAnalytics);
onINP(sendToAnalytics);
onLCP(sendToAnalytics);
```

## UTM Parameter Tracking

Umami automatically captures UTM parameters from URLs:

```
https://example.com/?utm_source=linkedin&utm_medium=social&utm_campaign=launch
```

Standard UTM parameters:
- `utm_source` — where traffic comes from (google, linkedin, newsletter)
- `utm_medium` — marketing medium (cpc, social, email)
- `utm_campaign` — campaign name (launch, spring-sale)

## References

| Topic | File | Load When |
|-------|------|-----------|
| Advanced patterns | [patterns.md](references/patterns.md) | Funnel tracking, A/B tests, dashboard queries, error tracking, privacy compliance |

## MUST DO

- Use Umami (self-hosted) for privacy-first analytics
- Follow consistent event naming: `action_object`
- Track Core Web Vitals with `web-vitals` library
- Track meaningful events (form submits, CTA clicks) not vanity metrics
- Use UTM parameters for campaign tracking

## MUST NOT

- Use Google Analytics without cookie consent banner
- Track personally identifiable information (PII)
- Skip event naming conventions — consistency enables analysis
- Track every click — focus on business-relevant events
- Use analytics scripts that block page rendering (always `defer`)
- Forget to verify analytics in staging before production
