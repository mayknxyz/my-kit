# /mykit.reset

Clear workflow state and start fresh.

## Usage

```
/mykit.reset [--keep-branch] [--keep-specs] [--force]
```

## Description

This command clears My Kit workflow state, allowing you to start a new workflow session without interference from previous sessions.

**Default behavior**:
- Deletes `.mykit/state.json` (session state)
- Preserves spec files in `specs/{branch}/`
- Preserves `.mykit/config.json`
- Does not switch branches

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| *(none)* | — | Executes directly |

## Flags

| Flag | Description |
|------|-------------|
| `--keep-branch` | Explicitly confirm branch preservation in output (semantic flag) |
| `--keep-specs` | Explicitly confirm spec file preservation in output (semantic flag) |
| `--force` | Skip confirmation and execute immediately |

## Implementation

When this command is invoked, execute the following steps in order:

### Step 1: Parse Arguments and Flags

Parse the command input to determine:
- `hasRunAction`: Whether `run` was provided
- `hasKeepBranch`: Whether `--keep-branch` flag is present
- `hasKeepSpecs`: Whether `--keep-specs` flag is present
- `hasForce`: Whether `--force` flag is present

**Validation**:
- If `--force` is provided without `run`, display warning and ignore `--force`

### Step 2: Check for State File

Check if `.mykit/state.json` exists:

```bash
test -f .mykit/state.json && echo "EXISTS" || echo "MISSING"
```

**If file is MISSING**, display the following and stop:

```markdown
# Reset

No state to reset. `.mykit/state.json` does not exist.

To start a new session, run `/mykit.start`.
```

### Step 3: Read State File Contents (for preview/confirmation)

If state file exists, read and parse its contents:

```bash
cat .mykit/state.json
```

Extract the following fields for display:
- `branch`: Branch name from saved state
- `lastCommand`: Last mykit command executed
- `timestamp`: When the state was last saved
- `workflowStage`: Current workflow stage
- `sessionType`: Type of workflow (major, minor, patch)

Calculate relative time from timestamp (e.g., "2 hours ago", "3 days ago").

### Step 4: Get Current Context

Get current branch name:

```bash
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
```

Check if spec files exist for the branch from state:

```bash
test -d "specs/{branch}" && echo "SPECS_EXIST" || echo "NO_SPECS"
```

### Step 5: Determine Mode and Execute

**If `run` action is NOT provided** (Preview Mode):

Display preview output showing what would be cleared:

```markdown
# Reset Preview

## State to Clear

**File**: `.mykit/state.json`
**Branch**: {branch from state}
**Last Command**: {lastCommand}
**Stage**: {workflowStage}
**Saved**: {timestamp} ({relativeTime})

## What Will Be Preserved

- Spec files in `specs/{branch}/` (default behavior){if hasKeepSpecs: " (--keep-specs confirmed)"}
- Current branch: `{currentBranch}`{if hasKeepBranch: " (--keep-branch confirmed)"}
- Configuration in `.mykit/config.json`

## To Execute

Run `/mykit.reset` to clear state.
```

**If `run` action IS provided** (Execute Mode):

If `--force` flag is present, skip to deletion step. Otherwise, proceed with deletion.

### Step 6: Delete State File

Execute the deletion:

```bash
rm .mykit/state.json
```

**If deletion fails**, display error and stop:

```markdown
# Reset Error

**Error**: Unable to delete `.mykit/state.json`
**Reason**: {error message from rm command}

Try manually removing the file or check permissions:
```bash
rm -f .mykit/state.json
```
```

### Step 7: Display Confirmation

**If deletion succeeds**, display confirmation:

```markdown
# Reset Complete

**Cleared**:
- `.mykit/state.json` deleted

**Preserved**:
- Spec files in `specs/{branch}/` {if specsExist: "✓" else: "(none found)"}{if hasKeepSpecs: " (--keep-specs)"}
- Current branch: `{currentBranch}` ✓{if hasKeepBranch: " (--keep-branch)"}
- Configuration: `.mykit/config.json` ✓

Session state cleared. Run `/mykit.start` to begin a new workflow.
```

**If both `--keep-branch` and `--keep-specs` flags are present**:

```markdown
# Reset Complete

**Cleared**:
- `.mykit/state.json` deleted

**Preserved** (as requested):
- Spec files in `specs/{branch}/` ✓ (--keep-specs)
- Current branch: `{currentBranch}` ✓ (--keep-branch)
- Configuration: `.mykit/config.json` ✓

Session state cleared. Run `/mykit.start` to begin a new workflow.
```

## Error Handling

| Error | Message |
|-------|---------|
| State file missing | "No state to reset. `.mykit/state.json` does not exist." |
| Permission denied | "Unable to delete `.mykit/state.json`. Check file permissions." |
| File system error | "Unable to delete `.mykit/state.json`. {error details}" |
| Invalid state file | Proceed with deletion regardless (corrupted files can still be deleted) |

## Example Output

### Preview Mode

```markdown
# Reset Preview

## State to Clear

**File**: `.mykit/state.json`
**Branch**: 007-resume-session
**Last Command**: /mykit.implement
**Stage**: implement
**Saved**: 2025-12-06T14:30:00Z (2 hours ago)

## What Will Be Preserved

- Spec files in `specs/007-resume-session/` (default behavior)
- Current branch: `007-resume-session`
- Configuration in `.mykit/config.json`

## To Execute

Run `/mykit.reset` to clear state.
```

### Execute Mode (Success)

```markdown
# Reset Complete

**Cleared**:
- `.mykit/state.json` deleted

**Preserved**:
- Spec files in `specs/007-resume-session/` ✓
- Current branch: `007-resume-session` ✓
- Configuration: `.mykit/config.json` ✓

Session state cleared. Run `/mykit.start` to begin a new workflow.
```

### Execute Mode with Flags

```markdown
# Reset Complete

**Cleared**:
- `.mykit/state.json` deleted

**Preserved** (as requested):
- Spec files in `specs/007-resume-session/` ✓ (--keep-specs)
- Current branch: `007-resume-session` ✓ (--keep-branch)
- Configuration: `.mykit/config.json` ✓

Session state cleared. Run `/mykit.start` to begin a new workflow.
```

### No State to Reset

```markdown
# Reset

No state to reset. `.mykit/state.json` does not exist.

To start a new session, run `/mykit.start`.
```

### Error Case

```markdown
# Reset Error

**Error**: Unable to delete `.mykit/state.json`
**Reason**: Permission denied

Try manually removing the file or check permissions:
```bash
rm -f .mykit/state.json
```
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.start` | Creates session state (opposite operation) |
| `/mykit.resume` | Reads session state (depends on state existing) |
| `/mykit.status` | Displays workflow status (unaffected by reset) |
| `/mykit.help` | Shows command documentation |
