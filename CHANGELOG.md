# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/mayknxyz/my-kit/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mayknxyz/my-kit/releases/tag/v0.1.0
