# Research: Session Purpose Prompt (/mykit.start)

**Branch**: `004-session-purpose` | **Date**: 2025-12-05

## Research Tasks

### 1. Claude Code Slash Command Pattern

**Decision**: Use markdown-based slash command with embedded instructions for Claude Code

**Rationale**:
- All existing `/mykit.*` commands follow this pattern
- Claude Code interprets markdown files in `.claude/commands/` as slash commands
- No external runtime or dependencies required
- Pattern is well-established in the codebase

**Alternatives Considered**:
- Shell script execution: Rejected - adds complexity, requires runtime validation
- External tool integration: Rejected - violates Simplicity principle

### 2. Chat-Based Selection Mechanism

**Decision**: Use `AskUserQuestion` tool pattern within the slash command prompt

**Rationale**:
- Standard Claude Code interaction pattern
- Provides numbered options (1, 2, 3) that users can reply to
- Supports text-based selection ("full", "lite", "quickfix")
- Already used in other My Kit commands (e.g., `/mykit.setup`)

**Alternatives Considered**:
- Argument-based selection (`/mykit.start full`): Rejected per clarification - chat-based preferred
- Interactive menu system: Rejected - not available in Claude Code slash command context

### 3. Session State Storage

**Decision**: In-memory state within Claude Code conversation context

**Rationale**:
- Specification clarified: session-scoped, resets when Claude Code session ends
- No file persistence needed (per clarification)
- State naturally maintained in conversation context
- Simplest possible approach - aligns with Constitution Principle V

**Alternatives Considered**:
- File-based storage (`.mykit/config.json`): Rejected per clarification
- Time-bounded expiration: Rejected per clarification

### 4. Direction to /mykit.backlog

**Decision**: Include instruction in command output to direct user to `/mykit.backlog`

**Rationale**:
- FR-004 requires directing user to backlog after selection
- Natural next step in workflow progression
- Can be included as part of confirmation message

**Alternatives Considered**:
- Automatic command chaining: Not supported in slash command pattern
- Required follow-up prompt: Adds friction, simple direction message preferred

## Dependencies

| Dependency | Status | Notes |
|------------|--------|-------|
| `/mykit.backlog` command | Exists | Stub implementation, receives users from `/mykit.start` |
| Claude Code CLI | Required | Target platform |
| `AskUserQuestion` tool | Built-in | Standard Claude Code tool |

## Unknowns Resolved

All NEEDS CLARIFICATION items resolved during `/speckit.clarify`:
1. ✅ Selection mechanism → Chat-based (user types "1", "2", "3" or option name)
2. ✅ Session state lifecycle → In-memory, session-scoped

## Conclusion

No external research required. Implementation uses established patterns from the existing codebase. All decisions align with Constitution principles, particularly Simplicity (V).
