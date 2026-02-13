# CLAUDE.md

Instructions for Claude Code when working in this repository.

## Project Overview

This is an [Astro](https://astro.build/) project — a content-focused web framework that ships minimal JavaScript by default using island architecture.

## Tech Stack

- **Astro** — static site generator with island architecture
- **TypeScript** — strict mode, no `any`
- **Tailwind CSS** — utility-first styling
- **Zod** — runtime validation for schemas and environment variables

## Project Structure (Atomic Design)

```
├── astro.config.mjs
├── tsconfig.json
├── package.json
├── public/                 # Static assets (served as-is)
├── src/
│   ├── components/
│   │   ├── atoms/          # Basic building blocks (Button, Input, Icon)
│   │   ├── molecules/      # Simple component groups (SearchBar, Card)
│   │   ├── organisms/      # Complex components (Header, Footer)
│   │   └── templates/      # Page layouts
│   ├── pages/              # File-based routing
│   ├── layouts/            # Shared layouts
│   ├── content/            # Content collections (blog, docs)
│   ├── lib/
│   │   ├── utils/          # Pure utility functions
│   │   ├── types/          # TypeScript type definitions
│   │   └── schemas/        # Zod validation schemas
│   ├── styles/             # Global styles
│   └── actions/            # Astro Actions (server-side form handlers)
└── docs/
```

## Development Commands

```bash
npm run dev          # Start dev server
npm run build        # Build for production
npm run preview      # Preview production build
npm run astro        # Run Astro CLI commands
```

## Core Principles

- **Server-first**: SSR/SSG by default, islands for interactivity only
- **Functional patterns**: Plain objects and functions, avoid OOP/classes
- **Type safety**: Strict TypeScript, no `any`, Zod for runtime validation
- **Progressive enhancement**: Works without JS, enhance with client directives
- **Performance**: Optimize bundles, Core Web Vitals, lazy loading

## Client Directives

Only add client directives when a component needs browser interactivity:

| Directive | When it loads | Use case |
|-----------|--------------|----------|
| `client:load` | Immediately on page load | Critical interactive UI |
| `client:idle` | After page is idle | Non-critical widgets |
| `client:visible` | When scrolled into viewport | Below-fold content |
| `client:media` | When media query matches | Responsive components |
| `client:only` | Never on server (client-only) | Browser-dependent code |
| _(none)_ | Static HTML only | Default — zero JS |

## Code Style

- Astro components: frontmatter (`---`) at top, markup in middle, scoped `<style>` at bottom
- TypeScript: strict mode, `import type` for type-only imports, explicit return types on exports
- Components: PascalCase (Button.astro), utilities: camelCase (formatDate.ts)
- 2-space indentation across all file types
- Slots over props for content injection

## Testing

- Build validation: `npm run build` must succeed
- Unit tests: Vitest for utility functions and business logic
- E2E tests: Playwright for critical user flows
- Lighthouse audits for performance, accessibility, SEO

## Project Principles

<!-- Filled by /mykit.init -->

## Workflow

- Default branch: `main`
- PR title format: `{version}: {title} (#{issue})`
- Auto-assign PRs: yes
- Draft PRs: no
- Auto-create branch on specify: yes
- Auto-fix linting: yes
- Version prefix: `v`
