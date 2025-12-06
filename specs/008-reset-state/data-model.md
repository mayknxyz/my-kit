# Data Model: /mykit.reset - Clear State

**Branch**: `008-reset-state` | **Date**: 2025-12-06

## Entities

### State File (`.mykit/state.json`)

The reset command targets this entity for deletion.

| Field | Type | Description |
|-------|------|-------------|
| version | string | Schema version (currently "1") |
| projectId | string | 8-character hash identifying the project |
| branch | string | Branch name when state was saved |
| lastCommand | string | Last mykit command executed |
| timestamp | string | ISO-8601 timestamp |
| workflowStage | enum | specify, clarify, plan, tasks, implement, complete |
| sessionType | enum | full, lite, quickfix |
| notes | string? | Optional user notes |

**Lifecycle**:
- Created by: `/mykit.start`
- Updated by: Various mykit commands
- Read by: `/mykit.resume`, `/mykit.status`
- **Deleted by**: `/mykit.reset run` ← This feature

### Spec Files (`specs/{branch}/`)

The reset command preserves these by default; acknowledges with `--keep-specs` flag.

| File | Purpose |
|------|---------|
| spec.md | Feature specification |
| plan.md | Implementation plan |
| tasks.md | Implementation tasks |
| research.md | Research findings |
| data-model.md | Data model documentation |
| quickstart.md | Quick start guide |
| checklists/ | Validation checklists |

**Lifecycle**:
- Created by: `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`
- **NOT deleted by**: `/mykit.reset run` (preserved by default)

### In-Memory Session State

Conversation context managed by Claude Code runtime.

| Aspect | Description |
|--------|-------------|
| Location | Claude Code conversation memory |
| Contents | Current workflow type, recent command context |
| Cleared by | Starting new conversation OR implicit with `/mykit.reset` execution |

## State Transitions

```
┌─────────────────┐
│  State Exists   │
│ (.mykit/state)  │
└────────┬────────┘
         │
         │ /mykit.reset run
         ▼
┌─────────────────┐
│  State Deleted  │
│  (clean slate)  │
└─────────────────┘
```

## Validation Rules

| Rule | Enforcement |
|------|-------------|
| State file must exist for meaningful reset | Display "No state to reset" if missing |
| Spec files preserved by default | Never delete unless explicitly requested (future flag) |
| Config file never touched | `.mykit/config.json` is separate from session state |

## Relationships

```
┌──────────────────────┐
│   .mykit/state.json  │ ◄── TARGET for deletion
└──────────────────────┘
         │
         │ references
         ▼
┌──────────────────────┐
│   specs/{branch}/    │ ◄── PRESERVED (default)
│   ├── spec.md        │
│   ├── plan.md        │
│   └── tasks.md       │
└──────────────────────┘
         │
         │ separate from
         ▼
┌──────────────────────┐
│  .mykit/config.json  │ ◄── NEVER TOUCHED
└──────────────────────┘
```
