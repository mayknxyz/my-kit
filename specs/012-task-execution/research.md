# Research: /mykit.implement - Task Execution

**Branch**: `012-task-execution` | **Date**: 2025-12-09

## Research Tasks

### R-001: Existing Command Patterns

**Task**: Analyze existing mykit commands for consistent patterns

**Findings**:
- Commands follow `/mykit.{name}` naming convention
- Stub files exist at `.claude/commands/mykit.{name}.md`
- Structure: Usage → Description → Implementation (step-by-step) → Error Handling → Example Outputs → Related Commands
- Arguments parsed for actions (e.g., `create`, `run`) and flags (e.g., `--force`)
- Git repository and feature branch validation is standard prerequisite

**Decision**: Follow `/mykit.tasks.md` as primary reference - similar scope and complexity

**Alternatives Considered**:
- `/mykit.status.md` - too read-only focused, lacks state mutation
- `/mykit.commit.md` - simpler action model, doesn't fit task lifecycle

### R-002: Task State Tracking Best Practices

**Task**: Determine best approach for tracking task states

**Findings**:
- Existing tasks.md uses standard markdown checkboxes: `- [ ]` and `- [x]`
- state.json is used by other commands for workflow context
- GitHub-flavored markdown supports only `[ ]` and `[x]` for checkboxes
- Custom markers (`[>]`, `[~]`) are visually distinct but not GitHub-rendered

**Decision**: Use extended checkbox markers with fallback compatibility
- `- [ ]` = pending (standard)
- `- [>]` = in-progress (displays as unchecked on GitHub, but visually distinct in text)
- `- [x]` = complete (standard)
- `- [~]` = skipped (displays as unchecked on GitHub, but visually distinct in text)

**Alternatives Considered**:
- State only in state.json - loses visual progress in tasks.md
- Emoji prefixes (`🔄`, `⏭️`) - inconsistent rendering, harder to parse
- Separate status column - breaks simple checkbox format

### R-003: Autonomous Execution Pattern

**Task**: Define how Claude Code executes tasks autonomously

**Findings**:
- Claude Code can read task descriptions and interpret intent
- Tasks contain natural language descriptions (e.g., "Implement Step 1: Git repository check")
- Some tasks reference commands (e.g., "Run validation: `/mykit.validate`")
- Tasks may reference file paths, functions, or code changes

**Decision**: Execution model varies by task type:
1. **Command tasks** (contains `/mykit.` or shell command): Execute the referenced command
2. **Code tasks** (references file paths, functions): Read context, write/edit code
3. **Validation tasks** (contains "verify", "test", "check"): Run appropriate validation

**Alternatives Considered**:
- Always ask user what to do - defeats autonomous execution goal
- Fixed execution templates - too rigid for diverse task types

### R-004: Session Resumption

**Task**: Ensure interrupted sessions can resume correctly

**Findings**:
- state.json persists across sessions
- tasks.md in-progress markers persist on disk
- `/mykit.resume` exists for session recovery
- Current task ID must be tracked for resumption

**Decision**: Store in state.json:
```json
{
  "workflow_step": "implement",
  "current_task": "T005",
  "tasks_path": "specs/012-task-execution/tasks.md",
  "last_command": "/mykit.implement",
  "last_command_time": "2025-12-09T10:30:00Z"
}
```

On resume: Read state.json, find task marked `[>]` in tasks.md, continue execution.

**Alternatives Considered**:
- Only use tasks.md markers - loses workflow context
- Only use state.json - loses visual progress for humans

### R-005: Completion Tasks Handling

**Task**: Define behavior for special completion tasks

**Findings**:
- tasks.md has separate "## Completion" section with:
  - Run validation: `/mykit.validate`
  - Create commit: `/mykit.commit create`
  - Create pull request: `/mykit.pr create`
- These are command invocations, not code tasks
- They follow the implementation tasks

**Decision**:
- Completion tasks execute like any other task
- When all implementation tasks complete, highlight transition to completion phase
- After final completion task, display celebration message and suggest `/mykit.pr create`

**Alternatives Considered**:
- Auto-execute completion tasks as a batch - loses granular control
- Skip completion tasks in /mykit.implement - breaks workflow continuity

## Summary

All research questions resolved. Key decisions:

| Topic | Decision |
|-------|----------|
| Command pattern | Follow /mykit.tasks.md structure |
| State tracking | Extended checkbox markers + state.json |
| Autonomous execution | Context-aware execution by task type |
| Session resumption | Dual tracking (tasks.md + state.json) |
| Completion tasks | Standard task execution with phase messaging |
