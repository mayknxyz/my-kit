# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- Resolve GNU Stow conflicts between my-claude and my-kit-v2 deployments

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

[Unreleased]: https://github.com/mayknxyz/my-kit-v2/compare/v2.0.3...HEAD
[2.0.3]: https://github.com/mayknxyz/my-kit-v2/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/mayknxyz/my-kit-v2/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/mayknxyz/my-kit-v2/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/mayknxyz/my-kit-v2/releases/tag/v2.0.0
