# CLAUDE.md

Instructions for Claude Code when working in this repository.

## Project Overview

This is a [SvelteKit](https://kit.svelte.dev/) project — a full-stack web framework using Svelte 5 with runes-based reactivity.

## Tech Stack

- **SvelteKit 2.x** — full-stack framework with file-based routing and SSR
- **Svelte 5** — runes-based reactivity (`$state`, `$derived`, `$effect`, `$props`)
- **TypeScript** — strict mode, no `any`
- **Tailwind CSS** — utility-first styling
- **Zod** — runtime validation for schemas and environment variables

## Project Structure (Feature-Based)

```
├── svelte.config.js
├── vite.config.ts
├── tsconfig.json
├── package.json
├── static/                 # Static assets (served as-is)
├── src/
│   ├── routes/             # File-based routing
│   │   ├── +page.svelte
│   │   ├── +layout.svelte
│   │   ├── +error.svelte
│   │   └── api/            # API routes (+server.ts)
│   ├── lib/
│   │   ├── components/
│   │   │   ├── ui/         # Base UI components (Button, Input, Card)
│   │   │   └── shared/     # Cross-feature components
│   │   ├── server/         # Server-only code (NOT sent to client)
│   │   │   ├── db/         # Database utilities
│   │   │   └── auth/       # Server-side auth logic
│   │   ├── stores/         # Global state (Svelte stores)
│   │   ├── utils/          # Pure utility functions
│   │   ├── types/          # TypeScript type definitions
│   │   └── schemas/        # Zod validation schemas
│   ├── hooks.server.ts     # Server hooks (auth, logging, security)
│   ├── hooks.client.ts     # Client error handling
│   └── app.css             # Global styles, Tailwind imports
└── docs/
```

## Development Commands

```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run preview      # Preview production build
npm run check        # Svelte check (type checking)
npm run lint         # ESLint
npm run format       # Prettier
npm run test         # Vitest unit tests
npm run test:e2e     # Playwright E2E tests
```

## Core Principles

- **Server-first**: SSR by default, progressive enhancement with `use:enhance`
- **Runes-based reactivity**: `$state` for local state, `$derived` for computed values, `$effect` for side effects, `$props` for component props
- **Functional patterns**: Plain objects and functions, avoid OOP/classes
- **Type safety**: Strict TypeScript, no `any`, Zod for runtime validation
- **Hybrid state**: Svelte stores for global state, runes for local/component state

## Svelte 5 Runes Quick Reference

| Rune | Purpose | Example |
|------|---------|---------|
| `$state` | Reactive state declaration | `let count = $state(0)` |
| `$derived` | Computed values | `let doubled = $derived(count * 2)` |
| `$derived.by` | Complex computed values | `$derived.by(() => { ... })` |
| `$effect` | Side effects | `$effect(() => { console.log(count) })` |
| `$props` | Component props | `let { name }: Props = $props()` |
| `$bindable` | Two-way bindable props | `let { value = $bindable() }: Props = $props()` |

## Code Style

- Svelte components: `<script lang="ts">` at top, markup in middle, scoped `<style>` at bottom
- TypeScript: strict mode, `import type` for type-only imports, explicit return types on exports
- Components: PascalCase (`Button.svelte`), utilities: camelCase (`formatDate.ts`)
- 2-space indentation across all file types
- Snippets over slots for content injection (Svelte 5)

## Testing

- Build validation: `npm run build` must succeed
- Svelte check: `npm run check` must pass
- Unit tests: Vitest for utility functions and business logic
- E2E tests: Playwright for critical user flows
- Lighthouse audits for performance, accessibility, SEO
