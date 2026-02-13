---
name: responsive
description: >
  Responsive design — mobile-first, fluid typography, container queries, responsive images.
  Use when implementing responsive layouts, breakpoints, fluid sizing, or responsive images.
  Triggers: responsive, mobile-first, breakpoints, fluid typography, clamp(), container queries,
  srcset, sizes, picture element, logical properties, viewport.
---

# Responsive Design

Senior responsive design engineer. Mobile-first. Fluid typography. Container queries. See `performance` skill for image optimization, `tailwind` skill for utility-based responsive.

## Mobile-First Breakpoints

```css
/* Mobile-first: min-width (additive) */
/* Base styles = mobile */
.layout { padding: 1rem; }

@media (min-width: 640px)  { /* sm — landscape phones */ }
@media (min-width: 768px)  { /* md — tablets */ }
@media (min-width: 1024px) { /* lg — laptops */ }
@media (min-width: 1280px) { /* xl — desktops */ }
```

In Tailwind v4: unprefixed = mobile, `sm:` = 640px+, `md:` = 768px+, etc.

## Fluid Typography

```css
/* clamp(min, preferred, max) */
h1 { font-size: clamp(2rem, 5vw + 1rem, 3.5rem); }
h2 { font-size: clamp(1.5rem, 3vw + 0.75rem, 2.5rem); }
h3 { font-size: clamp(1.25rem, 2vw + 0.5rem, 1.75rem); }
p  { font-size: clamp(1rem, 1vw + 0.75rem, 1.125rem); }

/* Fluid spacing */
section { padding-block: clamp(2rem, 5vw, 4rem); }
```

## Container Queries

```css
/* Component-level responsiveness */
.card-container { container-type: inline-size; container-name: card; }

@container card (min-width: 400px) {
  .card { flex-direction: row; }
  .card-image { width: 40%; }
}

@container card (min-width: 600px) {
  .card { gap: 2rem; }
  .card-title { font-size: 1.5rem; }
}
```

## Responsive Images

```html
<!-- srcset with width descriptors -->
<img
  src="/img/hero-800.webp"
  srcset="/img/hero-400.webp 400w, /img/hero-800.webp 800w, /img/hero-1200.webp 1200w"
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 800px"
  alt="Description"
  width="800" height="450"
  loading="lazy"
/>

<!-- Art direction with <picture> -->
<picture>
  <source media="(min-width: 768px)" srcset="/img/hero-wide.webp" />
  <source media="(min-width: 480px)" srcset="/img/hero-medium.webp" />
  <img src="/img/hero-mobile.webp" alt="Description" width="400" height="300" />
</picture>
```

## Logical Properties

```css
/* Physical (avoid) → Logical (prefer) */
margin-left    → margin-inline-start
margin-right   → margin-inline-end
padding-top    → padding-block-start
padding-bottom → padding-block-end
width          → inline-size
height         → block-size
text-align: left → text-align: start
border-left    → border-inline-start
```

## MUST DO

- Use mobile-first `min-width` media queries
- Use `clamp()` for fluid typography and spacing
- Use container queries for component-level responsiveness
- Use `srcset` and `sizes` for responsive images
- Set `width` and `height` on all images (prevents CLS)
- Use logical properties for RTL-ready layouts
- Include `<meta name="viewport" content="width=device-width, initial-scale=1">`

## MUST NOT

- Use `max-width` media queries — use `min-width` (mobile-first)
- Hardcode pixel widths for layout — use relative units, `clamp()`, flex/grid
- Forget viewport meta tag — page won't be responsive on mobile
- Use physical properties (`left`, `right`) when logical (`inline-start`, `inline-end`) work
- Serve single-size images to all viewports — use `srcset`
- Hide content on mobile with `display: none` — reorganize instead
