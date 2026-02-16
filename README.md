# My Kit v2

Skill-based development workflow toolkit for Claude Code. Manages the full development lifecycle from issue selection through specification, planning, implementation, and shipping.

## Setup

```bash
git clone git@github.com:mayknxyz/my-kit-v2.git ~/my-kit-v2
cd ~/my-kit-v2
stow -t ~ kit
```

This creates symlinks from `kit/.claude/` → `~/.claude/`, making all commands, skills, and agents globally available to Claude Code.

## What's Included

### Commands (21)

| Category | Commands |
|----------|----------|
| Setup | `/mykit.init`, `/mykit.sync` |
| Read-Only | `/mykit.status`, `/mykit.help` |
| Development | `/mykit.specify <issue#>`, `/mykit.plan`, `/mykit.tasks`, `/mykit.implement` |
| Ship | `/mykit.commit`, `/mykit.pr`, `/mykit.release` |
| Audit | `/mykit.audit.all`, `.quality`, `.security`, `.perf`, `.a11y`, `.deps` |
| Review | `/mykit.review.issues`, `/mykit.review.skills` |
| Utilities | `/mykit.log` |

### Skills (28)

**5 My Kit skills** — workflow, ship, ops, issues, and infrastructure:

| Skill | Auto-trigger | Purpose |
|-------|-------------|---------|
| `mykit` | No | Scripts, templates |
| `mykit-workflow` | Yes | 4 dev workflow steps |
| `mykit-ship` | Yes | Commit, PR, release pipeline |
| `mykit-ops` | Yes | Audit utilities |
| `mykit-issues` | Yes | Issue triage, deep-dive, bulk review |

**23 domain skills** — auto-triggered by project context:

a11y, analytics, animation, api-design, astro, biome, ci-cd, cloudflare, copywriting, database, design-system, feedback, git, performance, responsive, security, seo, svelte, tailwind, testing, typescript, web-core, zod.

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
cd ~/my-kit-v2 && git pull && stow -R -t ~ kit
```

Or use the command: `/mykit.sync`
