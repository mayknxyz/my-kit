---
name: design-system
description: >
  Design system architecture — CSS tokens, color scales, typography, spacing, component variants.
  Use when creating design tokens, theming, color scales, typography systems, or component
  variant patterns. Triggers: design system, design tokens, CSS custom properties, color scale,
  typography scale, spacing scale, theming, dark mode, component variants.
---

# Design System

Senior design system engineer. Token-driven. CSS custom properties. See `tailwind` skill for Tailwind `@theme` integration, `a11y` skill for contrast requirements.

## Token Architecture

```css
@theme {
  /* Colors — semantic naming */
  --color-primary: oklch(0.55 0.2 260);
  --color-secondary: oklch(0.65 0.15 330);
  --color-accent: oklch(0.7 0.18 150);

  /* State colors */
  --color-success: oklch(0.65 0.18 145);
  --color-warning: oklch(0.75 0.15 80);
  --color-error: oklch(0.6 0.2 25);

  /* Neutral scale */
  --color-gray-50: oklch(0.98 0 0);
  --color-gray-100: oklch(0.94 0 0);
  --color-gray-200: oklch(0.87 0 0);
  --color-gray-300: oklch(0.78 0 0);
  --color-gray-400: oklch(0.64 0 0);
  --color-gray-500: oklch(0.53 0 0);
  --color-gray-600: oklch(0.42 0 0);
  --color-gray-700: oklch(0.33 0 0);
  --color-gray-800: oklch(0.24 0 0);
  --color-gray-900: oklch(0.16 0 0);
  --color-gray-950: oklch(0.1 0 0);

  /* Surface & text (theme-aware) */
  --color-surface: var(--color-gray-50);
  --color-surface-elevated: white;
  --color-text: var(--color-gray-900);
  --color-text-muted: var(--color-gray-500);

  /* Typography */
  --font-sans: "Inter", system-ui, sans-serif;
  --font-heading: "Plus Jakarta Sans", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", monospace;

  /* Spacing (4px base) */
  --spacing-xs: 0.25rem;   /* 4px */
  --spacing-sm: 0.5rem;    /* 8px */
  --spacing-md: 1rem;      /* 16px */
  --spacing-lg: 1.5rem;    /* 24px */
  --spacing-xl: 2rem;      /* 32px */
  --spacing-2xl: 3rem;     /* 48px */
  --spacing-3xl: 4rem;     /* 64px */

  /* Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px oklch(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px oklch(0 0 0 / 0.07);
  --shadow-lg: 0 10px 15px oklch(0 0 0 / 0.1);
}
```

## Dark Mode Tokens

```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: var(--color-gray-950);
    --color-surface-elevated: var(--color-gray-900);
    --color-text: var(--color-gray-100);
    --color-text-muted: var(--color-gray-400);
  }
}
```

## Component Variants Pattern

```css
/* Size variants */
.btn { /* base styles */ }
.btn-sm { padding: var(--spacing-xs) var(--spacing-sm); font-size: 0.875rem; }
.btn-md { padding: var(--spacing-sm) var(--spacing-md); font-size: 1rem; }
.btn-lg { padding: var(--spacing-md) var(--spacing-lg); font-size: 1.125rem; }

/* Emphasis variants */
.btn-primary { background: var(--color-primary); color: white; }
.btn-secondary { background: var(--color-surface-elevated); color: var(--color-text); }
.btn-ghost { background: transparent; color: var(--color-primary); }
```

## MUST DO

- Define all design tokens as CSS custom properties
- Use semantic color names (primary, surface, text) not raw values
- Use oklch color space for perceptually uniform colors
- Define dark mode tokens that remap semantic variables
- Use consistent spacing scale (4px/8px base multiplier)
- Create size + emphasis variant system for components

## MUST NOT

- Hardcode colors or spacing values in components — use tokens
- Skip dark mode token definitions
- Use arbitrary magic numbers over scale values
- Mix color spaces (pick oklch and stay consistent)
- Create one-off colors outside the token system
- Forget state colors (success, warning, error, info)
