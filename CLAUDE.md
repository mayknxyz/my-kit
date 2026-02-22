# My Kit — Internal Reference

Architecture and rules reference for Claude Code.

## Structure

This is a **stow package**. The `kit/` directory mirrors `~/` and is deployed via GNU Stow:

```bash
cd ~/my-kit && stow -t ~ kit
```

This creates symlinks from `kit/.claude/` → `~/.claude/`, making commands, skills, and agents globally available.

## Architecture

### 6 My Kit Skills

| Skill | Purpose | Auto-trigger |
|-------|---------|-------------|
| `mykit` | Shared infrastructure (scripts, templates) | No (reference only) |
| `mykit-workflow` | Dev workflow (specify &lt;issue#&gt; → plan → tasks → implement) | Yes |
| `mykit-ship` | Ship pipeline (commit → pr → release) | Yes |
| `mykit-ops` | Utilities (audit) | Yes |
| `mykit-issues` | Issue analysis (triage → deep-dive → bulk review) | Yes |
| `mykit-repos` | Repo catalog & MCP management (repos.* → mcp.*) | Yes |

### 27 Domain Skills

Auto-triggered by context: a11y, analytics, animation, api-design, astro, biome, ci-cd, cloudflare, copywriting, database, design-system, diagrams, docs, feedback, git, performance, responsive, security, sentry, seo, sop, svelte, tailwind, testing, typescript, web-core, zod.

Skills with `references/` subdirectories: a11y, analytics, api-design, astro, cloudflare, copywriting, database, diagrams, docs, git, security, sentry, seo, sop, svelte, tailwind, testing, typescript, web-core.

### Commands (36 total)

- **12 full commands**: init, sync, help, status, log, issue.create, issue.edit, issue.view, issue.list, label.sync, ship.bypass, ship.approve
- **23 thin stubs**: specify (requires issue#), plan (requires spec.md), tasks (requires plan.md), implement, commit, pr, release, release.complete, release.bypass, audit.all, audit.quality, audit.security, audit.perf, audit.a11y, audit.deps, audit.linkcheck, review.issues, repos.review, repos.add, repos.remove, mcp.review, mcp.add, mcp.remove
- **1 utility**: review.skills

### 6 Audit Agents

mykit-audit-quality, mykit-audit-security, mykit-audit-perf, mykit-audit-a11y, mykit-audit-deps, mykit-audit-linkcheck.

## Path Convention

- **Infrastructure paths** (scripts, templates): `$HOME/.claude/skills/mykit/references/`
- **Scripts** use `$HOME/.claude/` prefix, not `~/.claude/`
- **Branch context**: All commands source `fetch-branch-info.sh` which sets `BRANCH`, `ISSUE_NUMBER`, `SPEC_PATH`, `PLAN_PATH`, `TASKS_PATH`

## Key Rules

1. **Never edit `~/.claude/` directly** — always edit files in `~/my-kit/kit/.claude/` and re-stow
2. **CLAUDE.md is the single source of truth** — project principles and workflow config live there
3. **Skills load one reference file per invocation** — they don't load everything at once
4. **Workflow steps chain** — specify requires issue#, plan requires spec.md, tasks requires plan.md
5. **Skills are auto-detected** — plan scans spec for domain skill keywords, tasks carries them to implement
6. **Canonical labels only** — all commands/skills must use labels from `$HOME/.claude/skills/mykit/references/labels.md`; never create labels outside this list
