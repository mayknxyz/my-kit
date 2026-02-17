---
name: tailwind
description: >
  Tailwind CSS v4 development with Vite plugin, @theme directive, and modern CSS patterns.
  Use when styling with Tailwind, configuring themes, using utility classes, or working with
  @theme blocks in CSS. Triggers: Tailwind, utility classes, @theme, @tailwindcss/vite,
  class:list, cn(), color-mix, CSS custom properties, dark mode tokens.
---

# Tailwind CSS v4

Senior Tailwind CSS v4 engineer. CSS-first configuration. Vite-native. See `astro` skill for Astro integration, `design-system` skill for token architecture.

## v4 Breaking Changes from v3

Tailwind v4 is a ground-up rewrite. Configuration moves from JavaScript to CSS.

| v3 (Legacy) | v4 (Current) |
|---|---|
| `tailwind.config.js` | `@theme` block in CSS |
| `theme.extend.colors` | CSS custom properties in `@theme` |
| `@tailwind base/components/utilities` | `@import "tailwindcss"` |
| PostCSS plugin | `@tailwindcss/vite` Vite plugin |
| `bg-opacity-50` | `bg-primary/50` or `color-mix()` |
| `darkMode: 'class'` | Built-in `dark:` via `prefers-color-scheme` |

## Configuration Pattern

```css
/* src/styles/global.css */
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.55 0.2 260);
  --color-secondary: oklch(0.65 0.15 330);
  --color-accent: oklch(0.7 0.18 150);
  --font-sans: "Inter", sans-serif;
  --font-heading: "Plus Jakarta Sans", sans-serif;
  --radius-lg: 0.75rem;
}
```

```ts
// astro.config.ts or vite.config.ts
import tailwindcss from "@tailwindcss/vite";
export default defineConfig({
  vite: { plugins: [tailwindcss()] },
});
```

## Key Patterns

- **Opacity**: Use slash syntax `bg-primary/50` or `color-mix(in oklch, var(--color-primary) 50%, transparent)`
- **Custom properties**: All `@theme` values become `--color-*`, `--font-*`, etc.
- **Layers**: Use `@layer base`, `@layer components`, `@layer utilities` for custom CSS
- **Astro class merging**: Use `class:list={["base", conditional && "active"]}` in `.astro` files
- **Dynamic merging**: Use `cn()` (clsx + twMerge) when merging props with defaults

## References

| Topic | File | Load When |
|-------|------|-----------|
| Advanced patterns | [patterns.md](references/patterns.md) | Plugin setup, @layer usage, complex color mixing, @theme extensions |

## MUST DO

- Use `@import "tailwindcss"` with `@tailwindcss/vite` plugin
- Define all design tokens in `@theme` block as CSS custom properties
- Use oklch color space for perceptually uniform colors
- Use `class:list` in Astro components for conditional classes
- Use `cn()` pattern when component accepts `class` prop to merge safely

## MUST NOT

- Use `tailwind.config.js` — v4 uses CSS-first `@theme` configuration
- Use v3 `theme.extend` syntax — define tokens directly in `@theme`
- Use `@apply` excessively — prefer utility classes in markup
- Use `@tailwind base/components/utilities` — use `@import "tailwindcss"`
- Use `bg-opacity-*` utilities — use slash syntax `bg-primary/50`
- Mix `tailwind.config.js` with `@theme` — pick one (always `@theme` for v4)

Docs: <https://tailwindcss.com/docs>
