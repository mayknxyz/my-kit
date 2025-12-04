# CLAUDE.md

Instructions for Claude Code when working in this repository.

## Project Overview

**My Kit** is a spec-driven development toolkit for Claude Code and GitHub. It provides `/mykit.*` slash commands that enforce a specification-first workflow.

## Key Concepts

- **Spec-Driven**: Define specifications before implementation
- **Issue-Linked**: All work tied to GitHub Issues
- **Action-Based Commands**: State-changing commands require an action (e.g., `create`, `run`)

## Command Pattern

```
/mykit.{command} [action] [flags]
```

- Read-only commands execute immediately: `/mykit.status`
- State-changing commands require action: `/mykit.commit create`

## Project Structure

```
.claude/commands/     # Slash command files (mykit.*.md)
.mykit/scripts/       # Shell utilities
.mykit/templates/     # Command templates
docs/                 # Documentation
```

## Development Guidelines

1. **Follow conventions** - See [docs/CONVENTIONS.md](docs/CONVENTIONS.md)
2. **Use conventional commits** - `feat:`, `fix:`, `docs:`, `refactor:`
3. **Shell scripts** - Follow Google Shell Style Guide, use shellcheck
4. **Preview by default** - Commands without action show preview

## Documentation

- [Commands](docs/COMMANDS.md) - Command reference
- [Conventions](docs/CONVENTIONS.md) - Development conventions
- [Blueprint](docs/001_BLUEPRINT.md) - Architecture and requirements

## Testing Commands

When implementing commands:
1. Test preview mode (no action)
2. Test execution mode (with action)
3. Test error handling
4. Test with and without `--force` flag

## Active Technologies
- Bash 4.0+ (POSIX-compatible shell script) + curl, git, gh CLI (validated at runtime) (001-curl-installer)
- File system only (`.claude/commands/`, `.mykit/scripts/`, `.mykit/config.json`) (001-curl-installer)

## Recent Changes
- 001-curl-installer: Added Bash 4.0+ (POSIX-compatible shell script) + curl, git, gh CLI (validated at runtime)
