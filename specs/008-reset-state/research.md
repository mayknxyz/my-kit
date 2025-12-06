# Research: /mykit.reset - Clear State

**Branch**: `008-reset-state` | **Date**: 2025-12-06

## Research Summary

This feature has minimal research requirements as it follows established patterns in the My Kit codebase. All technical decisions are resolved by examining existing implementations.

## Resolved Questions

### 1. Slash Command Structure Pattern

**Decision**: Follow the established pattern from `mykit.status.md` and `mykit.resume.md`

**Rationale**: Existing commands demonstrate the proven structure:
- Markdown file in `.claude/commands/`
- `## Usage` section with command syntax
- `## Implementation` section with step-by-step instructions
- `## Error Handling` table for edge cases
- `## Example Output` section for expected behavior

**Alternatives Considered**:
- Shell script implementation → Rejected: Other mykit commands use Markdown + Claude Code pattern
- External tool integration → Rejected: Adds unnecessary complexity, violates Simplicity principle

### 2. State File Location and Format

**Decision**: Target `.mykit/state.json` as the sole persistent state file

**Rationale**: Analysis of `mykit.resume.md` confirms:
- State file path: `.mykit/state.json`
- State schema: version, projectId, branch, lastCommand, timestamp, workflowStage, sessionType, notes
- File is created by `/mykit.start` and updated by other commands
- File is read by `/mykit.resume` for session continuity

**Alternatives Considered**:
- Multiple state files → Rejected: Single source of truth is simpler
- Different location → Rejected: Consistency with existing `.mykit/` convention

### 3. File Deletion Best Practices (Claude Code Context)

**Decision**: Use Claude Code's Bash tool with `rm` command for atomic file deletion

**Rationale**:
- Claude Code operates via Bash commands for file system operations
- Single `rm` command provides atomic deletion
- Checking file existence before deletion handles "no state to reset" gracefully
- Error handling via exit codes aligns with constitution exit code standards

**Alternatives Considered**:
- Complex file system API → Rejected: Not available in Claude Code context
- Write empty file instead of delete → Rejected: Leaves artifact, less clean

### 4. Preview vs Execute Pattern

**Decision**: Check file existence and display contents summary in preview mode

**Rationale**: Matches the pattern in other mykit commands:
- Preview shows what WOULD happen (dry-run)
- Execute (`run` action) performs the actual operation
- `--force` flag bypasses preview for experienced users

**Alternatives Considered**:
- Always require confirmation prompt → Rejected: `--force` flag provides this flexibility
- No preview mode → Rejected: Violates Constitution Principle III (Explicit Execution)

### 5. In-Memory State Handling

**Decision**: Document that in-memory session state is automatically cleared when reset executes, as it's part of the Claude Code conversation context

**Rationale**:
- Claude Code's conversation context IS the in-memory state
- When `/mykit.reset run` executes, the confirmation message serves as the new context
- No explicit "clear memory" action needed - it's implicit in the conversation flow

**Alternatives Considered**:
- Explicit memory clear command → Rejected: Not possible in Claude Code architecture
- Persist all state to file → Rejected: Over-engineering, current hybrid model works

## Dependencies Analysis

| Dependency | Purpose | Risk Level |
|------------|---------|------------|
| Claude Code | Runtime environment | None - required platform |
| Bash `rm` | File deletion | None - standard Unix utility |
| Bash `test -f` | File existence check | None - standard Unix utility |
| git CLI | Branch name detection (optional) | Low - only for display |

## No Unknowns Remaining

All NEEDS CLARIFICATION items from Technical Context have been resolved:
- ✅ Command structure pattern identified
- ✅ State file location confirmed
- ✅ File deletion approach determined
- ✅ Preview/execute pattern defined
- ✅ In-memory state handling understood

**Research Phase Complete** - Ready for Phase 1 Design
