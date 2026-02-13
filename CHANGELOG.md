# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/mayknxyz/my-kit-v2/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/mayknxyz/my-kit-v2/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/mayknxyz/my-kit-v2/releases/tag/v2.0.0
