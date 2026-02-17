# My Kit

Spec-driven, skill-based development workflow toolkit for Claude Code. Manages the full development lifecycle from issue selection through specification, planning, implementation, and shipping.

**Docs**: [mykit.mikenavales.xyz](https://mykit.mikenavales.xyz)

## Supported Stack

The domain skills are built for this specific stack. If your project uses a different framework or platform, the workflow commands still work but you won't get domain-specific guidance.

| Layer | Technologies |
|-------|-------------|
| Frameworks | **Astro**, **Svelte / SvelteKit** |
| Styling | **Tailwind CSS v4** |
| Language | **TypeScript** (strict mode) |
| Platform | **Cloudflare** (Pages, Workers, D1, KV, R2, Queues) |
| Validation | **Zod** |
| Tooling | **Biome** (lint/format), **Vitest** + **Playwright** (testing) |
| Monitoring | **Sentry** |

Not supported: React, Vue, Angular, Next.js, Nuxt, Node/Express, AWS, Vercel, Netlify, ESLint/Prettier, Jest, or other stacks.

## Setup

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [GNU Stow](https://www.gnu.org/software/stow/).

```bash
git clone https://github.com/mayknxyz/my-kit.git ~/my-kit
cd ~/my-kit
stow -t ~ kit
```

This creates symlinks from `kit/.claude/` → `~/.claude/`, making all commands, skills, and agents globally available to Claude Code.

## What's Included

### Commands (29)

| Category | Commands |
|----------|----------|
| Setup | `/mykit.init`, `/mykit.sync` |
| Read-Only | `/mykit.status`, `/mykit.help`, `/mykit.log` |
| Development | `/mykit.specify <issue#>`, `/mykit.plan`, `/mykit.tasks`, `/mykit.implement` |
| Issues | `/mykit.issue.create`, `.edit`, `.view`, `.list`, `/mykit.label.sync` |
| Ship | `/mykit.commit`, `/mykit.pr`, `/mykit.release`, `.complete`, `.bypass`, `/mykit.ship.approve`, `/mykit.ship.bypass` |
| Audit | `/mykit.audit.all`, `.quality`, `.security`, `.perf`, `.a11y`, `.deps` |
| Review | `/mykit.review.issues`, `/mykit.review.skills` |

### Skills (29)

**5 workflow skills** — framework-agnostic, work with any project:

| Skill | Auto-trigger | Purpose |
|-------|-------------|---------|
| `mykit` | No | Scripts, templates |
| `mykit-workflow` | Yes | 4 dev workflow steps |
| `mykit-ship` | Yes | Commit, PR, release pipeline |
| `mykit-ops` | Yes | Audit utilities |
| `mykit-issues` | Yes | Issue triage, deep-dive, bulk review |

**24 domain skills** — auto-triggered by project context, tuned for the supported stack:

| Category | Skills |
|----------|--------|
| Frameworks | astro, svelte |
| Styling & UI | tailwind, design-system, animation, responsive |
| Platform & Infra | cloudflare, database (D1/SQLite), ci-cd, sentry |
| Code Quality | typescript, biome, zod, testing, security, performance |
| Content & SEO | copywriting, seo, analytics, a11y |
| General | api-design, git, web-core, feedback |

### Agents (5)

Audit agents for parallel quality analysis: quality, security, performance, a11y, dependencies.

## Workflow

```
/mykit.specify 31 → /mykit.plan → /mykit.tasks → /mykit.implement →
/mykit.audit.all → /mykit.commit → /mykit.pr
```

Each step requires its predecessor: `specify` requires a GitHub issue number, `plan` requires `spec.md`, `tasks` requires `plan.md`. Skills are auto-detected during planning and carried through to implementation.

## Natural Language

You can also describe what you want in natural language — skills auto-activate:

```
"Write the spec for issue 31"       → mykit-workflow (specify step)
"Let's plan the implementation"     → mykit-workflow (plan step)
"Commit these changes"              → mykit-ship (commit step)
"Run a security audit"              → mykit-ops (audit step) or /mykit.audit.security
```

## Upgrading

```bash
cd ~/my-kit && git pull && stow -R -t ~ kit
```

Or use the command: `/mykit.sync`

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

[MIT](LICENSE)
