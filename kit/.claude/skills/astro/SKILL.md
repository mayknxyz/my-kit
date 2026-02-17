---
name: astro
description: >
  Astro 5.x development with Svelte islands, atomic design, and Cloudflare deployment.
  Use when working with Astro components, content collections, Svelte islands, client
  directives, SSR, routing, astro.config, atomic design patterns, or src/data/ layer.
  Triggers: Astro, .astro files, islands architecture, content collections, Svelte
  components, hybrid rendering, static site generation, atomic design.
---

# Astro Development

Senior Astro 5.x engineer. Atomic design architecture. Svelte for interactive islands. Ships zero JavaScript by default. Deploys to Cloudflare (see `cloudflare` skill for platform details, `sentry` skill for error tracking).

## Workflow

1. Determine output mode — `static` (default), `hybrid`, or `server`
2. Design atomic structure — atoms, molecules, organisms, templates
3. Implement components — Astro for static, Svelte islands for interactivity
4. Centralize content — `src/data/` for static sites, content collections for blogs
5. Add server features — API endpoints, actions, middleware as needed
6. Configure deployment — Cloudflare adapter, wrangler, bindings

## References

| Topic | File | Load When |
|-------|------|-----------|
| Component hierarchy + data layer | [atomic-design.md](references/atomic-design.md) | Structuring components, creating data files, project setup |
| Svelte hydration strategy | [svelte-islands.md](references/svelte-islands.md) | Adding interactivity, choosing client directives |
| Content Layer API (Astro 5) | [content-collections.md](references/content-collections.md) | Setting up blog/content, defining schemas, querying collections |
| Output modes + routing | [routing-ssr.md](references/routing-ssr.md) | Configuring SSR, creating API endpoints, prerender decisions |
| Coding conventions | [conventions.md](references/conventions.md) | Component patterns, content collections, styling, forms, testing |

## Tooling

- **Package manager**: Bun
- **Linting/formatting**: Biome
- **TypeScript**: `astro/tsconfigs/strict`
- **Styling**: Tailwind v4 via `@tailwindcss/vite` plugin + `@theme` directive in CSS
- **Fonts**: Self-hosted WOFF2 in `public/fonts/`

## MUST DO

- Follow atomic design: `atoms/` → `molecules/` → `organisms/` → `templates/`
- Centralize content in `src/data/` with typed TypeScript modules + barrel exports
- Use Tailwind v4 `@theme` directive in CSS (NOT `tailwind.config.js`)
- Prefer `client:visible` or `client:idle` over `client:load`
- Use Astro 5 content config path: `src/content.config.ts`
- Use `z.coerce.date()` for date fields in content schemas
- Access Cloudflare bindings via `Astro.locals.runtime.env`
- Set `export const prerender = false` for API routes and pages using bindings
- Self-host fonts as WOFF2 in `public/fonts/` with `font-display: swap`
- Define `interface Props` in every `.astro` component

## MUST NOT

- Hydrate components that do not need interactivity — zero JS is the default
- Use `import.meta.env` for Cloudflare secrets — use runtime bindings instead
- Use `z.date()` in content schemas — use `z.coerce.date()`
- Access `Astro.request` or `Astro.cookies` in prerendered pages
- Use Sharp image service on Cloudflare — set `imageService: "passthrough"` on the adapter
- Run `astro preview` with Cloudflare adapter — use `bunx wrangler pages dev dist` instead
- Use `tailwind.config.js` — Tailwind v4 uses `@theme` in CSS
- Hardcode content in components — use `src/data/` or content collections
- Use legacy `src/content/config.ts` path — Astro 5 uses `src/content.config.ts`

- Set `imageService: "passthrough"` on Cloudflare adapter when using CDN images (Cloudflare Images, imagedelivery.net)

## CLI

```
bun astro dev          # dev server
bun astro build        # production build
bun astro check        # TypeScript diagnostics
bun astro add <pkg>    # add integration
bun astro sync         # generate types
bunx wrangler pages dev dist  # preview (Cloudflare adapter does NOT support astro preview)
```

Docs: <https://docs.astro.build>
