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
| `mykit` | Shared infrastructure (scripts, templates, upstream) | No (reference only) |
| `mykit-workflow` | Dev workflow (specify → plan → tasks → implement → clarify → analyze → checklist) | Yes |
| `mykit-ship` | Ship pipeline (commit → pr → release) | Yes |
| `mykit-ops` | Utilities (audit, constitution, taskstoissues) | Yes |

### 23 Domain Skills

Auto-triggered by context: a11y, analytics, animation, api-design, astro, biome, ci-cd, cloudflare, copywriting, database, design-system, feedback, git, performance, responsive, security, seo, svelte, tailwind, testing, typescript, web-core, zod.

### Commands (25 total)

- **11 full commands**: start, init, setup, upgrade, sync, end, reset, resume, help, status, skill.review
- **13 thin stubs**: specify, plan, tasks, implement, clarify, analyze, checklist, commit, pr, release, audit, constitution, taskstoissues
- **1 standalone**: ship.md (from my-claude)

### 5 Audit Agents

mykit-audit-quality, mykit-audit-security, mykit-audit-perf, mykit-audit-a11y, mykit-audit-deps.

## Path Convention

- **Infrastructure paths** (scripts, templates, upstream): `$HOME/.claude/skills/mykit/references/`
- **Per-project paths** (state, config, memory): `.mykit/` (relative to project root)
- **Scripts** use `$HOME/.claude/` prefix, not `~/.claude/`

## Key Rules

1. **Never edit `~/.claude/` directly** — always edit files in `~/my-kit-v2/kit/.claude/` and re-stow
2. **Per-project state** lives in `.mykit/state.json` and `.mykit/config.json`
3. **Commands and skills share state** via `.mykit/state.json`
4. **Skills load one reference file per invocation** — they don't load everything at once
