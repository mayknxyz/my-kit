# /mykit.sync

Sync spec-kit upstream changes into the my-kit repo.

## Usage

```
/mykit.sync
```

- Executes directly: Sync spec-kit upstream changes

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Guard: My-Kit Repo Only

This command **only works inside the my-kit development repo** (~/my-kit or wherever the my-kit source is cloned).

**Detection**: Check if `$HOME/.claude/skills/mykit/references/upstream/` directory exists in the current repo.

**If NOT in the my-kit repo**, display this error and stop:

```
**Error**: `/mykit.sync` only works in the my-kit development repo.

This is a project repo. To update this project, run `/mykit.upgrade run` instead.
```

## Implementation

### Preview Mode (no action)

If no `run` action is provided:

1. Read `$HOME/.claude/skills/mykit/references/upstream/VERSION` to show current upstream version
2. Run: `$HOME/.claude/skills/mykit/references/scripts/sync-upstream.sh --dry-run`
3. Display summary of what would change

### Execute Mode (`run`)

1. Run: `$HOME/.claude/skills/mykit/references/scripts/sync-upstream.sh`
2. Show diff of what changed in `$HOME/.claude/skills/mykit-workflow/references/major/` and `$HOME/.claude/skills/mykit/references/templates/major/`
3. Run: `$HOME/.claude/skills/mykit/references/scripts/check-upstream-drift.sh`
4. Display summary:
   ```
   Synced spec-kit {old_version} → {new_version}.
   Review changes and commit when ready.
   ```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.upgrade` | Upgrades my-kit in project repos (different from sync) |
| `/mykit.start` | Shows spec-kit version warning when outdated |
| `/mykit.audit` | Can include drift check as part of quality checks |
