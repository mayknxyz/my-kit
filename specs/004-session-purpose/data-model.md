# Data Model: Session Purpose Prompt (/mykit.start)

**Branch**: `004-session-purpose` | **Date**: 2025-12-05

## Entities

### Session State

Represents the current workflow session configuration.

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| `session.type` | enum | Workflow type selected by user | Required, one of: "full", "lite", "quickfix" |

**Lifecycle**:
- Created: When user completes workflow selection in `/mykit.start`
- Persists: For duration of Claude Code session (in-memory)
- Destroyed: When Claude Code session ends

**State Values**:

| Value | Display Name | Description |
|-------|--------------|-------------|
| `full` | Full workflow (Spec Kit) | Complex features requiring specification, planning, and structured implementation |
| `lite` | Lite workflow (My Kit) | Simple changes that need some structure but not full spec-driven process |
| `quickfix` | Quick fix | Rapid fixes or minor changes with no formal planning overhead |

### Workflow Option

Represents a selectable workflow type displayed to the user.

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Display number (1, 2, or 3) |
| `name` | string | Short name shown in prompt |
| `description` | string | Brief explanation of when to use |
| `sessionType` | string | Value to store in `session.type` |

**Static Options**:

| ID | Name | Description | Session Type |
|----|------|-------------|--------------|
| 1 | Full workflow (Spec Kit) | Complex features | `full` |
| 2 | Lite workflow (My Kit) | Simple changes | `lite` |
| 3 | Quick fix | No formal planning | `quickfix` |

## State Transitions

```
[No Session] --(/mykit.start)--> [Prompting] --(user selects)--> [Session Active]
                                      |                                |
                                      v                                v
                              (invalid input)                  [Directed to /mykit.backlog]
                                      |
                                      v
                              [Re-prompt with valid options]
```

## Validation Rules

1. **Selection Input**: Must be one of:
   - Number: "1", "2", or "3"
   - Name (case-insensitive): "full", "lite", "quickfix"
   - Partial match: "full workflow", "spec kit", "lite workflow", "my kit", "quick fix"

2. **Invalid Input**: Re-prompt with valid options until valid selection received

## Relationships

```
Session State (1) ----references----> Workflow Option (1)
                                            |
                                            | determines
                                            v
                               Downstream command behavior
                               (/mykit.backlog, etc.)
```

## Notes

- No persistent storage required (in-memory only)
- Session state is conversation-scoped within Claude Code
- No database, file, or external API involved
