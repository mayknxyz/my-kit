# Research: Resume Interrupted Session

**Feature**: 007-resume-session
**Date**: 2025-12-06

## Research Tasks

### 1. State File Schema Design

**Decision**: Use a flat JSON structure with required and optional fields.

**Rationale**:
- Flat structure is easier to read, write, and debug
- Aligns with simplicity principle (Constitution V)
- Similar to how other CLI tools store session state (e.g., npm, yarn)

**Schema**:
```json
{
  "version": "1",
  "projectId": "<unique-project-identifier>",
  "branch": "<current-branch-name>",
  "lastCommand": "<last-executed-mykit-command>",
  "timestamp": "<ISO-8601-timestamp>",
  "workflowStage": "<specify|clarify|plan|tasks|implement|complete>",
  "sessionType": "<full|lite|quickfix>",
  "notes": "<optional-user-notes>"
}
```

**Alternatives Considered**:
1. Nested structure with workflow history - rejected (YAGNI, adds complexity)
2. Multiple state files per feature - rejected (harder to manage, overkill for single-user CLI)

### 2. Project Identifier Strategy

**Decision**: Use the git remote URL hash as the project identifier.

**Rationale**:
- Git remote URL is unique per repository
- Survives directory renames and moves
- Available via `git remote get-url origin`
- Hash (first 8 chars of SHA-256) provides compact identifier

**Implementation**:
```bash
# Generate project ID
git remote get-url origin 2>/dev/null | shasum -a 256 | cut -c1-8
```

**Fallback**: If no remote exists (local-only repo), use the absolute path of `.git` directory hashed.

**Alternatives Considered**:
1. Full remote URL - rejected (too long, contains credentials in some cases)
2. Repository name only - rejected (not unique across organizations)
3. UUID generated on first run - rejected (doesn't survive state file copies)

### 3. Workflow Stage Detection

**Decision**: Use file existence checks in `specs/{branch}/` directory.

**Rationale**:
- Consistent with existing `/mykit.status` implementation
- No additional state tracking needed
- Files are the source of truth

**Detection Logic**:
```
if tasks.md exists AND has incomplete tasks → "implement"
if tasks.md exists AND all tasks complete → "complete"
if plan.md exists → "tasks" (ready for task generation)
if spec.md exists → "plan" (ready for planning)
else → "specify" (no workflow started)
```

**Alternatives Considered**:
1. Store stage in state.json - rejected (duplicates file system truth)
2. Check git commits - rejected (complex, not reliable)

### 4. Stale State Detection

**Decision**: Use 7-day threshold based on timestamp field.

**Rationale**:
- 7 days covers typical work week + weekend gap
- Simple date comparison
- Matches assumption in spec

**Implementation**:
- Parse `timestamp` field from state.json
- Compare with current time
- If > 7 days, display warning

**Alternatives Considered**:
1. Configurable threshold - rejected (YAGNI, adds complexity)
2. Branch activity-based staleness - rejected (complex git operations)

### 5. Next Command Suggestion Logic

**Decision**: Use workflow stage + file status to determine suggestion.

**Rationale**:
- Mirrors `/mykit.status` logic for consistency
- Provides actionable guidance

**Suggestion Matrix**:

| Workflow Stage | Has Uncommitted Changes | Suggested Command |
|---------------|------------------------|-------------------|
| specify | No | `/speckit.specify` or `/mykit.backlog` |
| specify | Yes | `/mykit.commit create` |
| clarify | No | `/speckit.clarify` |
| clarify | Yes | `/mykit.commit create` |
| plan | No | `/speckit.plan` |
| plan | Yes | `/mykit.commit create` |
| tasks | No | `/speckit.tasks` |
| tasks | Yes | `/mykit.commit create` |
| implement | No | Continue implementation or `/mykit.pr create` |
| implement | Yes | `/mykit.commit create` |
| complete | Any | `/mykit.pr create` or `/mykit.backlog` |

**Alternatives Considered**:
1. AI-based suggestion - rejected (overkill, unpredictable)
2. Historical command patterns - rejected (adds complexity, YAGNI)

### 6. Display Format

**Decision**: Use structured card format with markdown sections.

**Rationale**:
- Matches clarification decision
- Consistent with `/mykit.status` output
- Easy to scan visually

**Template**:
```markdown
# Resume Session

## Last Session
**Branch**: {branch}
**Saved**: {timestamp} ({relative-time})
**Stage**: {workflowStage}
**Type**: {sessionType}

## Warnings
{warnings if any - branch mismatch, stale state, project mismatch}

## Suggested Next Step
`{command}` - {reason}
```

**Alternatives Considered**:
1. Single-line summary - rejected (per clarification decision)
2. JSON output - rejected (not user-friendly for primary use case; could add `--json` flag later)

## Resolved NEEDS CLARIFICATION

All technical context items resolved. No outstanding unknowns.
