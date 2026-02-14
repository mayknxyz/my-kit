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

### Commands (15)

| Category | Commands |
|----------|----------|
| Setup | `/mykit.init`, `/mykit.sync` |
| Read-Only | `/mykit.status`, `/mykit.help` |
| Development | `/mykit.specify`, `/mykit.plan`, `/mykit.tasks`, `/mykit.implement` |
| Ship | `/mykit.commit`, `/mykit.pr`, `/mykit.release` |
| Ops | `/mykit.audit` |
| Utilities | `/mykit.log`, `/mykit.skill.review` |

### Skills (27)

**4 My Kit skills** — workflow, ship, ops, and infrastructure:

| Skill | Auto-trigger | Purpose |
|-------|-------------|---------|
| `mykit` | No | Scripts, templates, version files |
| `mykit-workflow` | Yes | 4 dev workflow steps |
| `mykit-ship` | Yes | Commit, PR, release pipeline |
| `mykit-ops` | Yes | Audit utilities |

**23 domain skills** — auto-triggered by project context:

a11y, analytics, animation, api-design, astro, biome, ci-cd, cloudflare, copywriting, database, design-system, feedback, git, performance, responsive, security, seo, svelte, tailwind, testing, typescript, web-core, zod.

### Agents (5)

Audit agents for parallel quality analysis: quality, security, performance, a11y, dependencies.

## Workflow

```
/mykit.specify → /mykit.plan → /mykit.tasks → /mykit.implement →
/mykit.audit → /mykit.commit → /mykit.pr
```

For bug fixes and small changes, workflow steps are optional:

```
/mykit.specify → /mykit.implement → /mykit.commit → /mykit.pr
```

## Natural Language

You can also describe what you want in natural language — skills auto-activate:

```
"Write the spec for this feature"   → mykit-workflow (specify step)
"Let's plan the implementation"     → mykit-workflow (plan step)
"Commit these changes"              → mykit-ship (commit step)
"Run a security audit"              → mykit-ops (audit step)
```

## Upgrading

```bash
cd ~/my-kit-v2 && git pull && stow -R -t ~ kit
```

Or use the command: `/mykit.sync`
