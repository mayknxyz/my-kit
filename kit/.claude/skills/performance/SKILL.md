---
name: performance
description: >
  Web performance optimization — Core Web Vitals, font loading, image optimization, critical CSS.
  Use when optimizing page speed, fonts, images, or diagnosing CLS/LCP/INP issues. Triggers:
  performance, Core Web Vitals, LCP, CLS, INP, font loading, image optimization, lazy loading,
  preconnect, preload, critical CSS, WOFF2.
---

# Web Performance

Senior performance engineer. Core Web Vitals focused. See `astro` skill for Astro-specific optimizations, `responsive` skill for responsive images.

## Core Web Vitals

| Metric | Good | What Affects It |
|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2.5s | Hero images, fonts, server response time, render-blocking resources |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Images without dimensions, injected content, web fonts, ads |
| **INP** (Interaction to Next Paint) | < 200ms | Long tasks, heavy JS, main thread blocking, slow event handlers |

## Font Loading

```css
@font-face {
  font-family: "Inter";
  src: url("/fonts/inter-var.woff2") format("woff2");
  font-weight: 100 900;
  font-display: swap;
  unicode-range: U+0000-00FF; /* Latin subset */
}
```

```html
<!-- Preload critical fonts -->
<link rel="preload" href="/fonts/inter-var.woff2" as="font" type="font/woff2" crossorigin />
```

- Self-host fonts as WOFF2 (eliminate third-party requests)
- Use `font-display: swap` to prevent invisible text
- Subset fonts for used character ranges
- Use variable fonts to reduce file count

## Image Optimization

```html
<!-- Responsive with srcset -->
<img
  src="/img/hero-800.webp"
  srcset="/img/hero-400.webp 400w, /img/hero-800.webp 800w, /img/hero-1200.webp 1200w"
  sizes="(max-width: 768px) 100vw, 800px"
  alt="Description"
  width="800"
  height="450"
  loading="lazy"
  decoding="async"
/>
```

- **Always set `width` and `height`** — prevents CLS
- Use `loading="lazy"` for below-fold images
- Use `decoding="async"` to avoid blocking main thread
- Prefer WebP/AVIF formats over JPEG/PNG
- Use `fetchpriority="high"` on LCP hero image

## Resource Hints

```html
<!-- Preconnect to critical third-party origins -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="dns-prefetch" href="https://analytics.example.com" />

<!-- Preload critical resources -->
<link rel="preload" href="/critical.css" as="style" />
<link rel="modulepreload" href="/main.js" />
```

## CLI Tools

```bash
# Full-site audit
lighthouse http://localhost:4321 --output html --output-path ./report.html
lighthouse http://localhost:4321 --only-categories=performance --output json

# Scan entire site via sitemap
unlighthouse --site https://example.com

# SVG optimization
svgo input.svg -o output.svg             # single file
svgo -f ./src/icons -o ./src/icons       # folder (in-place)

# Font subsetting (requires Python fonttools)
glyphhanger http://localhost:4321 --subset=*.woff2 --formats=woff2
```

## MUST DO

- Set explicit `width` and `height` on all images (prevents CLS)
- Self-host fonts as WOFF2 with `font-display: swap`
- Use `loading="lazy"` on below-fold images
- Add `fetchpriority="high"` to LCP image
- Use `<link rel="preconnect">` for critical third-party origins
- Inline critical CSS for above-fold content

## MUST NOT

- Block rendering with external font stylesheets (self-host instead)
- Use images without explicit dimensions (causes CLS)
- Lazy-load above-fold / hero images (hurts LCP)
- Load large JS bundles synchronously in `<head>`
- Use unoptimized image formats (JPEG/PNG over WebP/AVIF)
- Animate layout properties (`width`, `height`) — use `transform` instead
