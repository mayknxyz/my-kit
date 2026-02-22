# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.10.0] - 2026-02-23

### Added

- `mykit-repos` skill — repo catalog and MCP server management with 6 steps (repos.review/add/remove, mcp.review/add/remove)
- `/mykit.repos.review` command — review repo catalog vs GitHub repos with auto-locate on disk
- `/mykit.repos.add` command — add repo to catalog with automatic stack and MCP detection
- `/mykit.repos.remove` command — remove repo from catalog with confirmation
- `/mykit.mcp.review` command — compare installed vs available MCP servers, detect config drift
- `/mykit.mcp.add` command — add MCP server from template with diff preview and confirmation
- `/mykit.mcp.remove` command — remove MCP server with diff preview and confirmation
- 7 MCP server templates: cloudflare, sentry, canva, claude-in-chrome-local, context7, browser-tools, sequential-thinking
- `data/repos.json` — version-controlled repo catalog with stack and MCP tracking schema

### Changed

- CLAUDE.md: My Kit skills 5 → 6, commands 30 → 36, thin stubs 17 → 23
- README.md: commands 29 → 36, skills 29 → 30, workflow skills 5 → 6, added Repos & MCP row, added missing audit.linkcheck
- mykit.help.md: added Repos & MCP section, updated Mode 4 valid commands list
- Ship approve command: find-or-create issue logic, changelog link conditional
- Git skill: branch naming deference note for project-specific commands
- Release reference: version bump conditional after merge, CHANGELOG-based release notes, branch capture note

## [2.9.0] - 2026-02-22

### Added

- `diagrams` domain skill — Mermaid flowcharts, sequence diagrams, ER diagrams, state machines, Gantt charts, C4 architecture with worked examples and syntax traps
- `docs` domain skill — Diataxis framework, README template, ADR template, TSDoc patterns, Keep a Changelog format
- `sop` domain skill — numbered checklists, incident runbooks, escalation matrices with 5-component structure and step writing rules

### Changed

- Domain skill count: 24 → 27 in CLAUDE.md
- Skills with `references/` subdirectories list updated to include diagrams, docs, sop

## [2.8.4] - 2026-02-18

### Added

- `/mykit.audit.linkcheck` command — run link check audit using lychee and linkinator
- `mykit-audit-linkcheck` subagent — runs both tools, deduplicates findings, writes structured report
- `linkcheck.sh` shell script — tool availability checks, scanning, result aggregation

### Changed

- Audit orchestrator: 5-domain → 6-domain (quality, security, perf, a11y, deps, linkcheck)
- CLAUDE.md: 29 → 30 commands, 16 → 17 thin stubs, 5 → 6 audit agents

## [2.8.3] - 2026-02-17

### Changed

- Ship commit reference: add version ownership note and shell script fallback guidance
- Ship PR reference: make label auto-detection required, add fallback when `labels.md` not found
- Ship release reference: rework to read version instead of recalculating, use `--delete-branch` on merge, add post-merge version bump step, simplify cleanup
- Workflow implement reference: add parallel execution guidance (Task tool) and context window management for resumable sessions

## [2.8.2] - 2026-02-17

### Changed

- Rename repo from `my-kit-v2` to `my-kit` — all file references updated
- README: add Supported Stack table, prerequisites, docs link, changelog link, categorized skills, HTTPS clone URL
- README: update tagline to "spec-driven, skill-based"
- CLAUDE.md: update heading to "Internal Reference", replace tagline with architecture context
- CI: rename `shellcheck.yml` → `lint.yml`, add markdownlint job

### Fixed

- Shellcheck: remove 4 unused `SCRIPT_DIR` variables, add `-x` flag for source resolution, suppress SC2317 false positive, replace sed with parameter expansion (SC2001)
- Markdownlint: add `.markdownlint-cli2.yaml` config, auto-fix formatting across 116 files (1694 → 0 issues)
- README: disambiguate duplicate `.bypass` in Ship command row
- `mykit.help.md`: fix heading level increment (MD001)
- `mykit.review.skills.md`: fix ordered list numbering (MD029)

### Added

- `.markdownlint-cli2.yaml` — project-wide markdownlint configuration
- `.gitignore`: add `specs/audit/` for generated audit reports

## [2.8.1] - 2026-02-17

### Added

- `.gitignore` — prevents local settings, env files, OS artifacts, and editor files from being committed
- MIT `LICENSE` file for open-source readiness

### Fixed

- README.md: command count 21 → 29, added Issues and Ship command categories
- README.md: skill count 28 → 29, domain skill count 23 → 24, added missing `sentry` skill
- README.md: added License section

## [2.8.0] - 2026-02-17

### Added

- `/mykit.issue.create` command — create GitHub issues from conversation context with auto-label detection
- `/mykit.issue.edit` command — edit existing issues (title, body, labels, assignees, milestone)
- `/mykit.issue.view` command — quick operational view of a single issue
- `/mykit.issue.list` command — quick list with optional state/label/assignee filters
- `/mykit.label.sync` command — enforce canonical labels on a repo (add missing, prompt for extras, re-label old issues)
- `/mykit.ship.approve` command — ship up to PR creation, stop for manual review
- `/mykit.ship.bypass` command — full ship pipeline with review step (replaces `/ship`)
- `labels.md` canonical label reference — 19 labels (9 GitHub defaults + 10 custom) with auto-detection keywords
- Key Rule #6 in CLAUDE.md: canonical labels only, never create labels outside the list
- Merged branch detection in `/mykit.status` — shows "Completed" phase, suggests cleanup actions

### Changed

- All label-using commands/skills now read from canonical list instead of `gh label list`
- Updated: `pr.md`, `triage.md`, `bulk-review.md`, `mykit.pr.md` template for canonical label enforcement
- CLAUDE.md: command count 21 → 27, full commands 5 → 12
- Performance SKILL.md: add sentry cross-reference

### Removed

- `/ship` command (replaced by `/mykit.ship.bypass` and `/mykit.ship.approve`)

## [2.7.0] - 2026-02-16

### Added

- New `sentry` domain skill for error tracking and performance monitoring on Cloudflare Pages
- SDK decision guide covering SvelteKit, Astro, Vanilla (HTML/JS), and Cloudflare Worker stacks
- `references/sveltekit-cloudflare.md` — full SvelteKit + Cloudflare setup (vite plugin, hooks, user context)
- `references/astro-cloudflare.md` — full Astro + Cloudflare setup (integration, middleware, static variant)
- `references/patterns.md` — error reporting patterns (manual capture, breadcrumbs, performance spans, alerting)
- Cross-references to sentry skill in astro, cloudflare, security, and svelte SKILL.md files

### Changed

- CLAUDE.md: domain skill count 23 → 24, added sentry to auto-trigger and references lists

## [2.6.2] - 2026-02-16

### Fixed

- Ship command: add user interruption/correction handling note to version selection step
- Ship command: clarify working tree inspection wording — use `git status` and `git diff` instead of ambiguous "staged/unstaged files and diffs"

## [2.6.1] - 2026-02-16

### Fixed

- Add dirty working tree guard before fetch — errors if uncommitted changes exist
- Fetch failure now short-circuits with local info instead of comparing stale remote
- Add `git checkout main` before pull to handle detached HEAD from version pinning
- Use `--ff-only` on pull to prevent unexpected merge commits
- Remove unused `$ARGUMENTS` section (sync takes no arguments)

## [2.6.0] - 2026-02-16

### Added

- `/mykit.audit.all` command — runs all audit domains (renamed from `/mykit.audit`)
- `/mykit.audit.quality` command — run quality audit only (shellcheck, markdownlint)
- `/mykit.audit.security` command — run security audit only (gitleaks)
- `/mykit.audit.perf` command — run performance audit only (AI analysis)
- `/mykit.audit.a11y` command — run accessibility audit only (AI analysis)
- `/mykit.audit.deps` command — run dependency audit only (AI analysis)
- Commands table in audit reference listing all `/mykit.audit.*` commands
- Domain-specific trigger keywords in mykit-ops SKILL.md

### Changed

- Rename `/mykit.audit` → `/mykit.audit.all`
- Rename `/mykit.issues` → `/mykit.review.issues`
- Rename `/mykit.skill.review` → `/mykit.review.skills`
- Update mykit.help.md with new Audit section and updated command lists
- Update workflow templates to reference `/mykit.audit.all`
- Update CLAUDE.md and README.md command counts (16 → 21)

### Removed

- `/mykit.audit` command (replaced by `/mykit.audit.all`)
- `/mykit.issues` command (replaced by `/mykit.review.issues`)
- `/mykit.skill.review` command (replaced by `/mykit.review.skills`)

## [2.5.2] - 2026-02-16

### Added

- Plan Mode Rule in mykit-workflow — prefer `/mykit.plan` over native `EnterPlanMode` when spec file exists
- Scope Expansion section in implement reference — append new tasks mid-implementation without breaking the loop
- Broaden skills detection in tasks reference — scan spec/plan for additional skill keywords beyond plan's original list
- `git-ops.sh` quick reference table in commit reference — function signatures for faster lookups

### Changed

- Commit pre-stage safety check now includes `.dev.vars` (Cloudflare convention) in sensitive file patterns

## [2.5.1] - 2026-02-16

### Added

- `agent-file-template.md` template for `update-agent-context.sh` new agent file creation
- Top 5 Recommendations section to triage report output
- Key Recommendations section to deep-dive report output

### Changed

- Flatten `templates/minor/` — moved `spec.md`, `plan.md`, `tasks.md` to `templates/` directly
- `tasks.md` template updated to flat list format; `/mykit.tasks` workflow wired to use it
- Standardized all 15 domain skill reference tables to "Topic | File | Load When" format
- Updated 3 script template paths (`create-new-feature.sh`, `setup-plan.sh`, `update-agent-context.sh`)

### Removed

- `templates/minor/` subdirectory (files promoted to `templates/`)
- Unused `ARGS=()` variable from `setup-plan.sh`

## [2.5.0] - 2026-02-15

### Added

- `fetch-branch-info.sh` shared script — resolves BRANCH, ISSUE_NUMBER, SPEC_PATH, PLAN_PATH, TASKS_PATH; sourced by all commands
- `issue-review.md` reference — reviews extracted issue details, flags gaps, provides recommendations during specify step
- Pre-stage safety check in commit workflow — scans for sensitive files (.env, keys, credentials) before staging
- Auto-detect domain skills during plan step — scans spec for keyword matches against 23 skills
- Status field in tasks.md — set to `Pending` by tasks, updated to `Complete` by implement

### Changed

- `/mykit.specify` now requires issue number argument (e.g., `/mykit.specify 31`)
- `/mykit.init` simplified to 2-phase flow (framework + principles); workflow preferences use defaults
- `/mykit.plan` requires spec.md as prerequisite (was standalone)
- `/mykit.tasks` requires plan.md as prerequisite (was standalone with guided fallback)
- `/mykit.implement` loads skills from tasks.md; read-only operations skip permission prompts
- `/mykit.commit` auto-generates type, scope, description, and version bump from context (was 4 interactive prompts)
- `/mykit.pr` auto-generates title, description, and labels from artifacts (was interactive menu with View/Update/Close)
- `/mykit.release` simplified to 6 steps (was 16 + routing menu with flags)
- `/mykit.status` and `/mykit.help` updated for new workflow conventions
- Workflow references moved from `references/minor/` to `references/`
- All commands source `fetch-branch-info.sh` instead of inline branch/issue extraction
- Skills carried through chain: plan detects → tasks copies → implement loads

### Removed

- `references/minor/` directory (files moved to `references/`)
- Interactive prompts from commit (type, scope, description, breaking, version bump, confirm)
- Interactive routing menu from PR (View/Update/Close) and release (Create/View with flags)
- Guided conversation fallback from tasks (plan prerequisite guarantees artifacts)
- Ad-hoc spec path generation (issue number now required)
- CRUD flags and `--force` from release command
- Redundant git repo/feature branch validation (handled by prerequisite chain)

## [2.4.0] - 2026-02-14

### Added

- Reference files for 5 domain skills: `security/references/patterns.md`, `testing/references/patterns.md`, `a11y/references/patterns.md`, `seo/references/patterns.md`, `api-design/references/patterns.md`
- `## References` routing tables in security, testing, a11y, seo, api-design SKILL.md files
- `.github/workflows/shellcheck.yml` — ShellCheck CI for bash scripts on push/PR
- `v2.0.0` git tag on initial commit (was missing)

### Changed

- Commit skill (`commit.md`): added Step 11b to update `package.json` version when updating CHANGELOG
- README.md: updated to 5 My Kit skills and 16 commands (added mykit-issues)
- CLAUDE.md: updated skills with `references/` list (9 → 15)

### Removed

- `VERSION` file (unused — git tags are the source of truth)
- `scripts/.gitkeep` (directory contains real files)

## [2.3.0] - 2026-02-14

### Added

- `references/migrations.md` for database skill: multi-environment D1 migration workflow (local → preview → production)
- Migration verification commands, pre-deployment checklist, common pitfalls, and rollback patterns

### Changed

- database SKILL.md: add `migration workflow` and `environment` trigger keywords
- database SKILL.md: add `## References` table pointing to `references/migrations.md`
- database SKILL.md: add migration-discipline items to MUST DO / MUST NOT sections

## [2.2.0] - 2026-02-14

### Added

- Reference files for 5 domain skills: tailwind/patterns.md, analytics/patterns.md, typescript/advanced.md, git/workflows.md, copywriting/patterns.md
- `## References` routing tables in tailwind, analytics, typescript, git, copywriting SKILL.md files
- `load_feature_paths()` wrapper in utils.sh to encapsulate eval pattern
- Trap handlers in create-new-feature.sh, setup-plan.sh, git-ops.sh
- Source error guards in check-prerequisites.sh, setup-plan.sh, update-agent-context.sh
- Copy error checks in create-new-feature.sh, setup-plan.sh

### Changed

- README.md: fix command count (18→15), remove deleted commands, update mykit-ops purpose
- CLAUDE.md: note 9 domain skills with references/ subdirectories
- All 8 shell scripts now use `set -euo pipefail` consistently
- 3 callers updated from `eval "$(get_feature_paths)"` to `load_feature_paths`
- `get_feature_paths()` now escapes single quotes in paths to prevent injection
- feedback SKILL.md expanded with evaluation checklist, improvement patterns, good-vs-bad examples
- create-new-feature.sh: fix grep pipefail issue with `{ grep || true; }` guard

## [2.1.0] - 2026-02-14

### Added

- New `mykit-issues` skill for read-only GitHub issue analysis (triage, deep-dive, bulk review)
- `/mykit.issues` command with argument-based routing (no args → triage, number → deep-dive, keyword → bulk review)
- Triage operation: completeness, clarity, staleness analysis, duplicate detection, label suggestions
- Deep-dive operation: single issue analysis with codebase search and implementation suggestions
- Bulk review operation: categorization, duplicate detection, health metrics, top 5 recommendations

### Changed

- CLAUDE.md updated to reflect 5 My Kit Skills (was 4) and 16 Commands (was 15)

## [2.0.4] - 2026-02-14

### Added

- R2 presigned URL generation pattern for browser uploads to cloudflare skill
- R2 CORS configuration guide and browser upload checklist to cloudflare skill
- Authenticated R2 proxy pattern for serving private files to cloudflare skill
- Local dev gotcha for R2 binding vs S3 API mismatch to cloudflare skill

### Changed

- Add `blob:` to CSP `img-src` directive in security skill for object URL previews

## [2.0.3] - 2026-02-14

### Changed

- Merge `/mykit.init` + `/mykit.setup` + `/mykit.constitution` into unified `/mykit.init`
- CLAUDE.md is now the single source of truth (principles + workflow config)
- Move CONVENTIONS.md content into framework skills (astro, svelte, web-core)
- Ship skill references read workflow preferences from CLAUDE.md instead of config.json
- Framework CLAUDE.md templates include Project Principles and Workflow sections
- mykit-ops skill now handles audit only

### Removed

- Commands: `/mykit.setup`, `/mykit.constitution`, `/mykit.taskstoissues`
- `.mykit/` directory (config.json, memory/constitution.md)
- `setup-wizard.sh` interactive onboarding script
- Config functions from utils.sh (read_config, get_config_field, get_config_field_or_default)
- Constitution Check table from plan template
- CONVENTIONS.md from framework templates (moved to skills)

## [2.0.2] - 2026-02-13

### Changed

- Collapse 3 workflow modes (major/minor/patch) into single workflow based on minor files
- Replace `/mykit.upgrade` with `/mykit.sync` for install/upgrade from any directory
- Rename `/mykit.end` to `/mykit.log` with simplified git-only data gathering
- Version bump type now asked at commit time instead of session start
- All commands use AskUserQuestion for interactive routing instead of CRUD flags
- Update all template commands, scripts, and skills to match simplified architecture

### Removed

- spec-kit upstream mirror (SPEC_KIT_VERSION, upstream/ directory, sync scripts)
- state.json persistence — derive everything from git + file existence
- Major-only workflow steps: `/mykit.clarify`, `/mykit.analyze`, `/mykit.checklist`
- Patch workflow variant (4 files)
- Commands: `/mykit.start`, `/mykit.resume`, `/mykit.reset`, `/mykit.upgrade`
- 5 scripts: version.sh, upgrade.sh, github-api.sh, sync-upstream.sh, check-upstream-drift.sh
- CRUD flag parsing (-c/-r/-u/-d) and --force flags from all commands
- State management functions from utils.sh (read_state, write_state, update_state_field, get_state_field)

## [2.0.1] - 2026-02-13

### Fixed

- Update settings.json permission patterns for v2 script paths
- Resolve GNU Stow conflicts between my-claude and my-kit deployments

## [2.0.0] - 2026-02-13

### Added

- Skill-based architecture with 4 mykit skills (mykit, mykit-workflow, mykit-ship, mykit-ops)
- 23 domain skills migrated from my-claude (a11y, analytics, animation, api-design, astro, biome, ci-cd, cloudflare, copywriting, database, design-system, feedback, git, performance, responsive, security, seo, svelte, tailwind, testing, typescript, web-core, zod)
- Natural language invocation via auto-triggered skills
- 13 thin command stubs delegating to skills (specify, plan, tasks, implement, clarify, analyze, checklist, commit, pr, release, audit, constitution, taskstoissues)
- GNU Stow deployment (`stow -t ~ kit`) replacing install.sh
- 5 formal audit agents (quality, security, perf, a11y, deps)
- Shared routing patterns in mykit-workflow/references/routing.md

### Changed

- Architecture: 24 monolithic commands → 4 skills + 13 thin stubs + 11 full commands
- Deployment: install.sh → GNU Stow package
- Upgrade: curl/tarball download → `git pull && stow -R -t ~ kit`
- Infrastructure paths: `.mykit/scripts/` → `$HOME/.claude/skills/mykit/references/scripts/`
- Mode files: `.mykit/modes/` → mykit-workflow skill references
- Subagents: `.mykit/subagents/` → `kit/.claude/agents/`
- ship.md command migrated from my-claude
- VERSION starts at v2.0.0

### Removed

- install.sh (replaced by stow)
- Monolithic command routing (replaced by skill routing)
- Per-project infrastructure file copies (now globally shared via stow symlinks)

[Unreleased]: https://github.com/mayknxyz/my-kit/compare/v2.10.0...HEAD
[2.10.0]: https://github.com/mayknxyz/my-kit/compare/v2.9.0...v2.10.0
[2.9.0]: https://github.com/mayknxyz/my-kit/compare/v2.8.4...v2.9.0
[2.8.4]: https://github.com/mayknxyz/my-kit/compare/v2.8.3...v2.8.4
[2.8.3]: https://github.com/mayknxyz/my-kit/compare/v2.8.2...v2.8.3
[2.8.2]: https://github.com/mayknxyz/my-kit/compare/v2.8.1...v2.8.2
[2.8.1]: https://github.com/mayknxyz/my-kit/compare/v2.8.0...v2.8.1
[2.8.0]: https://github.com/mayknxyz/my-kit/compare/v2.7.0...v2.8.0
[2.7.0]: https://github.com/mayknxyz/my-kit/compare/v2.6.2...v2.7.0
[2.6.2]: https://github.com/mayknxyz/my-kit/compare/v2.6.1...v2.6.2
[2.6.1]: https://github.com/mayknxyz/my-kit/compare/v2.6.0...v2.6.1
[2.6.0]: https://github.com/mayknxyz/my-kit/compare/v2.5.2...v2.6.0
[2.5.2]: https://github.com/mayknxyz/my-kit/compare/v2.5.1...v2.5.2
[2.5.1]: https://github.com/mayknxyz/my-kit/compare/v2.5.0...v2.5.1
[2.5.0]: https://github.com/mayknxyz/my-kit/compare/v2.4.0...v2.5.0
[2.4.0]: https://github.com/mayknxyz/my-kit/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/mayknxyz/my-kit/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/mayknxyz/my-kit/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/mayknxyz/my-kit/compare/v2.0.4...v2.1.0
[2.0.4]: https://github.com/mayknxyz/my-kit/compare/v2.0.3...v2.0.4
[2.0.3]: https://github.com/mayknxyz/my-kit/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/mayknxyz/my-kit/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/mayknxyz/my-kit/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/mayknxyz/my-kit/releases/tag/v2.0.0
