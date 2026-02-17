# Tailwind CSS v4 Advanced Patterns

## Custom `@theme` Extensions

### Responsive Tokens

```css
@theme {
  --breakpoint-xs: 475px;
  --container-3xs: 16rem;
  --container-2xs: 18rem;
  --spacing-18: 4.5rem;
  --spacing-88: 22rem;
}
```

### Container Breakpoints

```css
@theme {
  --container-sm: 640px;
  --container-md: 768px;
  --container-lg: 1024px;
  --container-xl: 1280px;
}
```

Use with container queries: `@container (min-width: var(--container-md))`.

## `@layer` Patterns

Use Tailwind's three layers for custom CSS that respects the cascade:

```css
/* Base — resets, global defaults */
@layer base {
  html {
    font-family: var(--font-sans);
    scroll-behavior: smooth;
  }

  :focus-visible {
    outline: 2px solid var(--color-primary);
    outline-offset: 2px;
  }
}

/* Components — reusable patterns */
@layer components {
  .btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    border-radius: var(--radius-lg);
    font-weight: 500;
  }

  .card {
    border-radius: var(--radius-lg);
    background: var(--color-surface);
    box-shadow: var(--shadow-sm);
  }
}

/* Utilities — single-purpose helpers */
@layer utilities {
  .text-balance {
    text-wrap: balance;
  }

  .scrollbar-hidden {
    scrollbar-width: none;
    &::-webkit-scrollbar { display: none; }
  }
}
```

When to use each layer:

- **base**: Element-level defaults, CSS resets, global typography
- **components**: Multi-property patterns reused across pages (cards, buttons, badges)
- **utilities**: Single-purpose helpers not provided by Tailwind

## Plugin Usage

### Typography Plugin

```bash
npm install @tailwindcss/typography
```

```css
@import "tailwindcss";
@plugin "@tailwindcss/typography";
```

Apply with `prose` class: `<article class="prose prose-lg">`.

### Forms Plugin

```bash
npm install @tailwindcss/forms
```

```css
@plugin "@tailwindcss/forms";
```

Resets form elements to a consistent baseline. Override with utility classes.

### Container Queries Plugin

```bash
npm install @tailwindcss/container-queries
```

```css
@plugin "@tailwindcss/container-queries";
```

```html
<div class="@container">
  <div class="@md:grid-cols-2 @lg:grid-cols-3">
    <!-- Responsive to container, not viewport -->
  </div>
</div>
```

## Complex Color Patterns

### `color-mix()` Recipes

```css
/* Transparent variant */
background: color-mix(in oklch, var(--color-primary) 10%, transparent);

/* Blend two theme colors */
border-color: color-mix(in oklch, var(--color-primary) 50%, var(--color-secondary));

/* Lighten/darken */
background: color-mix(in oklch, var(--color-primary), white 20%);
background: color-mix(in oklch, var(--color-primary), black 20%);
```

### Dark Mode Token Overrides

```css
@theme {
  --color-surface: oklch(0.99 0 0);
  --color-surface-alt: oklch(0.96 0 0);
  --color-text: oklch(0.15 0 0);
  --color-text-muted: oklch(0.45 0 0);
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-surface: oklch(0.15 0 0);
    --color-surface-alt: oklch(0.2 0 0);
    --color-text: oklch(0.93 0 0);
    --color-text-muted: oklch(0.65 0 0);
  }
}
```

### Forced Dark Mode (Class-based)

```css
.dark {
  --color-surface: oklch(0.15 0 0);
  --color-text: oklch(0.93 0 0);
}
```

Toggle with `<html class="dark">` and JavaScript.

## Performance

### Content Path Optimization

Tailwind v4 auto-detects content sources. For monorepos or custom setups, use `@source`:

```css
@source "../components/**/*.{astro,svelte,ts}";
@source "../layouts/**/*.astro";
```

Exclude irrelevant directories to speed up builds.

### Safelist Patterns

For classes generated dynamically (CMS content, user data):

```css
@source inline("bg-red-500 bg-blue-500 bg-green-500");
```

Only safelist classes that are genuinely dynamic. Static content is auto-scanned.
