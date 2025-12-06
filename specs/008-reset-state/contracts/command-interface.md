# Command Interface Contract: /mykit.reset

**Branch**: `008-reset-state` | **Date**: 2025-12-06

## Command Signature

```
/mykit.reset [run] [--keep-branch] [--keep-specs] [--force]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `run` | No | Execute the reset (without it, shows preview) |

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--keep-branch` | - | Explicitly preserve current branch (semantic flag) |
| `--keep-specs` | - | Explicitly confirm spec preservation in output |
| `--force` | - | Skip preview, execute immediately |

## Behavior Matrix

| Command | Mode | Action |
|---------|------|--------|
| `/mykit.reset` | Preview | Show what would be cleared |
| `/mykit.reset run` | Execute | Delete state file, confirm |
| `/mykit.reset run --force` | Force | Execute immediately, no preview |
| `/mykit.reset run --keep-branch` | Execute | Delete state, confirm branch preserved |
| `/mykit.reset run --keep-specs` | Execute | Delete state, confirm specs preserved |
| `/mykit.reset run --keep-branch --keep-specs` | Execute | Delete state, confirm both preserved |

## Output Contract

### Preview Mode Output

```markdown
# Reset Preview

## State to Clear

**File**: `.mykit/state.json`
**Branch**: {branch from state}
**Last Command**: {lastCommand}
**Saved**: {timestamp} ({relative time})

## What Will Be Preserved

- Spec files in `specs/{branch}/` (default behavior)
- Current branch: `{current branch}`
- Configuration in `.mykit/config.json`

## To Execute

Run `/mykit.reset run` to clear state.
```

### Execute Mode Output (Success)

```markdown
# Reset Complete

**Cleared**:
- `.mykit/state.json` deleted

**Preserved**:
- Spec files in `specs/{branch}/` ✓
- Current branch: `{branch}` ✓
- Configuration: `.mykit/config.json` ✓

Session state cleared. Run `/mykit.start` to begin a new workflow.
```

### Execute Mode Output (No State)

```markdown
# Reset

No state to reset. `.mykit/state.json` does not exist.

To start a new session, run `/mykit.start`.
```

### Error Output

```markdown
# Reset Error

**Error**: Unable to delete `.mykit/state.json`
**Reason**: {error message}

Try manually removing the file or check permissions.
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (or no state to reset) |
| 1 | Error deleting state file |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.start` | Creates state file (opposite operation) |
| `/mykit.resume` | Reads state file (depends on state existing) |
| `/mykit.status` | Displays state info (unaffected by reset) |
