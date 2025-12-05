# Research: /mykit.help Command

**Branch**: `005-help` | **Date**: 2025-12-06

## Research Summary

This document captures research findings for implementing the `/mykit.help` command. No NEEDS CLARIFICATION items were identified in the technical context - all decisions are straightforward given the existing codebase patterns.

## Key Decisions

### 1. Command Argument Parsing

**Decision**: Use Claude Code's built-in `$ARGUMENTS` variable for parsing command input.

**Rationale**: This is the established pattern across all existing `/mykit.*` commands. The arguments will be parsed as:
- Empty → Show categorized command list (FR-001)
- `<command-name>` → Show detailed help for that command (FR-004)
- `workflow` → Show workflow cheatsheets (FR-007)

**Alternatives Considered**:
- Flag-based parsing (`--command=X`) - Rejected: Inconsistent with spec clarification that positional arguments should be used.

### 2. Command Metadata Source

**Decision**: Source command data from `docs/COMMANDS.md` as the single source of truth.

**Rationale**:
- `docs/COMMANDS.md` already contains comprehensive command information including categories, actions, flags, and examples.
- Individual command files (`.claude/commands/mykit.*.md`) have inconsistent detail levels (some are stubs).
- FR-008 requires "authoritative command files" - `docs/COMMANDS.md` is the authoritative reference.

**Alternatives Considered**:
- Parse each `.claude/commands/mykit.*.md` file individually - Rejected: Inconsistent metadata, many are stubs.
- Maintain separate help registry file - Rejected: Violates simplicity principle; duplicates existing docs.

### 3. Output Format

**Decision**: Use markdown tables and code blocks matching existing `docs/COMMANDS.md` format.

**Rationale**:
- Claude Code renders markdown natively in terminal.
- Existing docs already format correctly for 80-column display (SC-004).
- Consistent visual language with documentation.

**Alternatives Considered**:
- Plain text with ASCII art - Rejected: Less readable, harder to maintain.
- JSON output - Rejected: Not human-readable for primary use case.

### 4. Error Handling for Unknown Commands

**Decision**: Display helpful error message with all available command names for user to identify the correct one.

**Rationale**:
- FR-006 requires "suggestions for similar commands."
- With only 17 commands, listing all is more helpful than fuzzy matching.
- Keeps implementation simple (no string similarity algorithm needed).

**Alternatives Considered**:
- Levenshtein distance for fuzzy suggestions - Rejected: Over-engineering for 17 commands.
- Simple prefix matching - Rejected: May miss useful suggestions.

### 5. Implementation Status Detection

**Decision**: Check for `**Stub**` marker in individual command files to determine implementation status.

**Rationale**:
- FR-009 requires indicating stub vs implemented status.
- Existing stub commands use consistent `**Stub** - Implementation pending.` format.
- Simple string match is reliable and maintainable.

**Alternatives Considered**:
- Maintain separate status registry - Rejected: Duplicates information, can drift.
- Check for specific implementation patterns - Rejected: Fragile, varies by command type.

## Technology Patterns

### Claude Code Slash Command Pattern

The help command follows established patterns:

```markdown
# /mykit.help [topic]

[Description of what help does]

## Behavior

When topic is empty:
  - Display categorized command list from docs/COMMANDS.md

When topic is a command name (e.g., "commit"):
  - Read .claude/commands/mykit.{topic}.md
  - Display description, usage, actions, flags, examples
  - Check for **Stub** marker and indicate status

When topic is "workflow":
  - Display workflow cheatsheets from docs/COMMANDS.md
```

### File Reading Pattern

```text
1. Read docs/COMMANDS.md for structured command data
2. For specific command help, read .claude/commands/mykit.{name}.md
3. Parse markdown headings and tables for metadata extraction
```

## Open Questions Resolved

| Question | Resolution |
|----------|------------|
| How to handle typos? | List all commands; user identifies correct one |
| Which syntax for workflow? | Positional: `/mykit.help workflow` (per clarification) |
| Repository context needed? | No - works anywhere (per clarification) |
| Stub detection method | Check for `**Stub**` text in command file |

## Next Steps

Phase 1 will:
1. Define the command metadata model in `data-model.md`
2. No API contracts needed (read-only markdown command)
3. Create `quickstart.md` with implementation guidance
