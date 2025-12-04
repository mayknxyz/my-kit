# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-12-05

### Added
- Self-upgrade command (`/mykit.upgrade`) for in-place updates
- Version utilities (`version.sh`) for version checking and comparison
- Upgrade utilities (`upgrade.sh`) for backup, restore, and installation
- Preview mode showing current version, latest version, and changelog
- Version listing with release dates and current/latest markers
- Version pinning to upgrade or downgrade to specific versions
- Downgrade warnings when targeting older versions

### Features
- Automatic backup before upgrade to `.mykit/backup/.last-backup/`
- Automatic rollback on upgrade failure
- Lock file prevents concurrent upgrade operations
- Cross-platform SHA-256 checksum support (sha256sum/shasum/openssl)
- Modified file detection via manifest comparison
- Configuration preservation (`.mykit/config.json` never overwritten)

### Infrastructure
- Exit codes per CLI interface contract (0-4)
- Dependency validation (curl, git, gh CLI)
- Network error handling with troubleshooting guidance

## [0.1.0] - 2025-12-04

### Added
- Curl-based installer (`install.sh`) for one-line installation
- Stub command files for all `/mykit.*` slash commands
- Shell utility scripts (utils, github-api, git-ops, validation)
- Lite workflow templates (spec, plan, tasks)
- Project constitution defining core principles
- Feature specification workflow (`specs/001-curl-installer/`)

### Infrastructure
- Atomic installation with rollback on failure
- Signal trapping for clean interruption handling
- Prerequisite validation (git, gh CLI, git repository)
- Platform-specific installation guidance

[Unreleased]: https://github.com/mayknxyz/my-kit/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/mayknxyz/my-kit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/mayknxyz/my-kit/releases/tag/v0.1.0
