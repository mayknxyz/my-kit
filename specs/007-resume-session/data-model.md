# Data Model: Resume Interrupted Session

**Feature**: 007-resume-session
**Date**: 2025-12-06

## Entities

### SessionState

Represents the saved context of a work session.

**Location**: `.mykit/state.json`

**Schema**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| version | string | Yes | Schema version (currently "1") |
| projectId | string | Yes | 8-character hash identifying the project |
| branch | string | Yes | Branch name when state was saved |
| lastCommand | string | Yes | Last mykit command executed |
| timestamp | string | Yes | ISO-8601 timestamp of when state was saved |
| workflowStage | enum | Yes | Current workflow stage (see WorkflowStage) |
| sessionType | enum | Yes | Type of workflow session (see SessionType) |
| notes | string | No | Optional user notes or context |

**Example**:
```json
{
  "version": "1",
  "projectId": "a1b2c3d4",
  "branch": "007-resume-session",
  "lastCommand": "/speckit.plan",
  "timestamp": "2025-12-06T14:30:00Z",
  "workflowStage": "plan",
  "sessionType": "full",
  "notes": "Working on resume command implementation"
}
```

### WorkflowStage (Enum)

Indicates progress in the spec-driven workflow.

| Value | Description | Next Logical Step |
|-------|-------------|-------------------|
| specify | Specification not started or in progress | `/speckit.specify` or `/speckit.clarify` |
| clarify | Specification exists, clarification in progress | `/speckit.clarify` |
| plan | Specification complete, planning in progress | `/speckit.plan` |
| tasks | Plan complete, tasks generation needed | `/speckit.tasks` |
| implement | Tasks exist, implementation in progress | Continue coding |
| complete | All tasks done, ready for PR | `/mykit.pr create` |

### SessionType (Enum)

Type of workflow selected via `/mykit.start`.

| Value | Description |
|-------|-------------|
| full | Full workflow (Spec Kit) - complex features |
| lite | Lite workflow (My Kit) - simpler changes |
| quickfix | Quick fix - rapid changes, minimal planning |

### ProjectIdentifier

A derived value (not stored separately) used to validate state belongs to current project.

**Generation**:
```
SHA-256(git remote get-url origin)[0:8]
```

**Fallback** (no remote):
```
SHA-256(absolute path of .git directory)[0:8]
```

## Relationships

```
SessionState
├── contains → WorkflowStage (enum value)
├── contains → SessionType (enum value)
└── references → ProjectIdentifier (for validation)
```

## Validation Rules

### State File Validation

| Rule | Action on Failure |
|------|-------------------|
| File must be valid JSON | Display error, suggest starting fresh |
| version must be "1" | Display error, suggest upgrading/clearing |
| projectId must match current project | Display warning, suggest clearing state |
| branch must be a string | Display error, suggest starting fresh |
| timestamp must be valid ISO-8601 | Display warning (continue with "unknown" timestamp) |
| workflowStage must be valid enum value | Default to "specify" with warning |
| sessionType must be valid enum value | Default to "full" with warning |

### Staleness Validation

| Condition | Action |
|-----------|--------|
| timestamp > 7 days old | Display warning about stale state |
| branch no longer exists in git | Display warning, branch marked as missing |
| Current branch differs from saved | Display warning, continue with note |

## State Transitions

This command is **read-only** and does not modify state. State transitions are handled by other commands:

- `/mykit.start` → Creates initial state with sessionType
- `/speckit.specify` → Updates workflowStage to "specify" or "clarify"
- `/speckit.plan` → Updates workflowStage to "plan"
- `/speckit.tasks` → Updates workflowStage to "tasks"
- Task completion → Updates workflowStage to "implement" or "complete"
- `/mykit.commit` → Updates lastCommand and timestamp

## Data Lifecycle

| Event | State File Behavior |
|-------|---------------------|
| Project setup (`/mykit.setup`) | Creates `.mykit/` directory if missing |
| Session start (`/mykit.start`) | Creates/updates state.json |
| Command execution | Updates lastCommand, timestamp |
| Session resume (`/mykit.resume`) | **Read-only** - displays state, no writes |
| Branch switch | State reflects old branch until next command |
| Project clone | No state.json exists until first /mykit.start |
