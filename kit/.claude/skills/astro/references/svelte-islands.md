# Svelte Islands

## Setup

```bash
npx astro add svelte
```

This adds `@astrojs/svelte` to `astro.config.mjs` and creates `svelte.config.js`.

Place `.svelte` files in `src/components/` following atomic design hierarchy.

## Islands Principle

Zero JavaScript is the default. Only hydrate Svelte components that **require client-side interactivity**. Static content stays in `.astro` components.

## Client Directive Decision Tree

```
Does this component need JavaScript in the browser?
│
├─ NO → Use .astro component (no directive, no JS shipped)
│
└─ YES → Is it above the fold and needed immediately?
   │
   ├─ YES, immediate → client:load
   │                    (hydrates on page load)
   │
   ├─ YES, can wait → client:idle
   │                   (hydrates when browser is idle)
   │
   └─ NO, below fold or conditional:
      │
      ├─ Visible on scroll → client:visible
      │                      (hydrates when scrolled into view)
      │
      ├─ Responsive only → client:media="(max-width: 768px)"
      │                    (hydrates when media query matches)
      │
      └─ Uses browser APIs (window/document) → client:only="svelte"
                                                (client render only, NO SSR)
```

## Priority (lightest to heaviest)

| Directive | JS Shipped | SSR | Hydration Trigger |
|-----------|-----------|-----|-------------------|
| _(none)_ | No | Yes | Never |
| `client:visible` | Yes | Yes | Scroll into viewport |
| `client:media` | Yes | Yes | Media query match |
| `client:idle` | Yes | Yes | Browser idle |
| `client:load` | Yes | Yes | Page load |
| `client:only="svelte"` | Yes | **No** | Page load (client render) |

## Gotchas

- **Props must be serializable** — no functions, classes, or Maps. Only JSON-compatible values.
- **`client:only="svelte"`** skips SSR entirely — content invisible without JS. Always specify the `"svelte"` string.
- **Test without JS** — pages should still render meaningful content when directives haven't hydrated yet.
- **Svelte 5 runes** — `$props()` works seamlessly with Astro prop passing.

Docs: <https://docs.astro.build/en/guides/integrations-guide/svelte/>
