# Quickstart: /mykit.reset

**Branch**: `008-reset-state` | **Date**: 2025-12-06

## What It Does

The `/mykit.reset` command clears My Kit workflow state, allowing you to start fresh without residual session data interfering with a new workflow.

## Quick Usage

### Preview What Will Be Cleared

```
/mykit.reset
```

Shows what state exists and what would be cleared, without actually clearing anything.

### Clear State

```
/mykit.reset run
```

Deletes `.mykit/state.json` and confirms what was preserved.

### Clear State Immediately (Skip Preview)

```
/mykit.reset run --force
```

Executes reset without showing preview first.

## What Gets Cleared

| Item | Cleared? |
|------|----------|
| `.mykit/state.json` | ✅ Yes |
| In-memory session context | ✅ Yes (implicit) |

## What's Preserved

| Item | Preserved? |
|------|------------|
| Spec files (`specs/{branch}/`) | ✅ Always |
| Configuration (`.mykit/config.json`) | ✅ Always |
| Current git branch | ✅ Always |
| Uncommitted changes | ✅ Always |

## Common Scenarios

### Scenario 1: Start Over on Same Feature

You've been working on a feature but want to restart the workflow:

```
/mykit.reset run --keep-specs
```

Clears session state but keeps your specification work.

### Scenario 2: Complete Clean Slate

You want to abandon current work and start completely fresh:

```
/mykit.reset run
```

Then checkout main and start a new feature:

```bash
git checkout main
```

```
/mykit.start
```

### Scenario 3: Quick Check Before Reset

Not sure what state exists?

```
/mykit.reset
```

Review the preview, then decide whether to proceed.

## After Reset

Run one of these to begin a new workflow:

- `/mykit.start` - Begin a new session with workflow selection
- `/mykit.status` - Check current project status
- `/mykit.backlog` - Select an issue to work on
