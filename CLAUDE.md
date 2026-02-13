# My Kit v2

Skill-based development workflow toolkit for Claude Code.

## Structure

This is a **stow package**. The `kit/` directory mirrors `~/` and is deployed via GNU Stow:

```bash
cd ~/my-kit-v2 && stow -t ~ kit
```

This creates symlinks from `kit/.claude/` → `~/.claude/`, making commands, skills, and agents globally available.

## Architecture

### 4 My Kit Skills

| Skill | Purpose | Auto-trigger |
|-------|---------|-------------|
| `mykit` | Shared infrastructure (scripts, templates) | No (reference only) |
| `mykit-workflow` | Dev workflow (specify → plan → tasks → implement) | Yes |
| `mykit-ship` | Ship pipeline (commit → pr → release) | Yes |
| `mykit-ops` | Utilities (audit) | Yes |

### 23 Domain Skills

Auto-triggered by context: a11y, analytics, animation, api-design, astro, biome, ci-cd, cloudflare, copywriting, database, design-system, feedback, git, performance, responsive, security, seo, svelte, tailwind, testing, typescript, web-core, zod.

### Commands (15 total)

- **5 full commands**: init, sync, help, status, log
- **8 thin stubs**: specify, plan, tasks, implement, commit, pr, release, audit
- **1 standalone**: ship.md (from my-claude)
- **1 utility**: skill.review

### 5 Audit Agents

mykit-audit-quality, mykit-audit-security, mykit-audit-perf, mykit-audit-a11y, mykit-audit-deps.

## Path Convention

- **Infrastructure paths** (scripts, templates): `$HOME/.claude/skills/mykit/references/`
- **Scripts** use `$HOME/.claude/` prefix, not `~/.claude/`

## Key Rules

1. **Never edit `~/.claude/` directly** — always edit files in `~/my-kit-v2/kit/.claude/` and re-stow
2. **CLAUDE.md is the single source of truth** — project principles and workflow config live there
3. **Skills load one reference file per invocation** — they don't load everything at once
