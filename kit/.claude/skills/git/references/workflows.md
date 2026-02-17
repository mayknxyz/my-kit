# Git Advanced Workflows

## Rebase Workflows

### Interactive Rebase

Clean up commit history before merging:

```bash
# Rebase last 5 commits interactively
git rebase -i HEAD~5

# Rebase onto main (all commits since branch point)
git rebase -i main
```

Interactive rebase commands:

- `pick` — keep commit as-is
- `reword` — change commit message
- `squash` — combine with previous commit (keep message)
- `fixup` — combine with previous commit (discard message)
- `drop` — remove commit entirely

### Squash Before Merge

Combine all feature branch commits into one clean commit:

```bash
# On feature branch, squash all commits since branching from main
git rebase -i main
# Mark all but the first commit as 'squash' or 'fixup'
```

### Rebase vs Merge

| Use Rebase | Use Merge |
|---|---|
| Feature branch onto main (clean history) | Merging main into long-lived branches |
| Cleaning up local commits before push | Shared branches with collaborators |
| Linear history preferred | Preserving merge context matters |

Golden rule: never rebase commits that have been pushed to a shared branch.

## Cherry-Pick

### Selective Backporting

Apply specific commits to another branch:

```bash
# Apply a single commit
git cherry-pick abc123

# Apply a range of commits (exclusive start, inclusive end)
git cherry-pick abc123..def456

# Apply without committing (stage changes only)
git cherry-pick --no-commit abc123

# Cherry-pick a merge commit (specify parent)
git cherry-pick -m 1 abc123
```

### Avoiding Conflicts

- Cherry-pick the oldest commit first when picking a sequence
- Use `--no-commit` to batch multiple picks, then commit once
- If conflicts arise, resolve and `git cherry-pick --continue`

## Stash Patterns

### Named Stashes

```bash
# Stash with a descriptive message
git stash push -m "WIP: contact form validation"

# List stashes with names
git stash list
# stash@{0}: On feature/contact: WIP: contact form validation

# Apply by index
git stash apply stash@{0}
```

### Partial Stashes

Stash only specific files or hunks:

```bash
# Stash specific files
git stash push -m "stash styles only" -- src/styles/

# Interactive: choose which hunks to stash
git stash push -p -m "partial stash"
```

### Pop vs Apply

- `git stash pop` — apply and remove from stash list (use for one-time restores)
- `git stash apply` — apply but keep in stash list (use when you may need it again)

```bash
# Drop a stash without applying
git stash drop stash@{2}

# Clear all stashes
git stash clear
```

## Conflict Resolution

### Strategies

```bash
# Accept all of ours (current branch)
git checkout --ours path/to/file

# Accept all of theirs (incoming branch)
git checkout --theirs path/to/file

# Use a three-way merge tool
git mergetool
```

### Resolution Workflow

1. `git status` — identify conflicted files
2. Open each file, find `<<<<<<<` markers
3. Edit to desired result, remove markers
4. `git add <resolved-file>` — mark as resolved
5. `git rebase --continue` or `git merge --continue`

### When to Abort

```bash
# Abort a rebase in progress
git rebase --abort

# Abort a merge in progress
git merge --abort

# Abort a cherry-pick in progress
git cherry-pick --abort
```

Abort when: conflicts are too complex to resolve confidently, you realize you're on the wrong branch, or upstream has changed significantly.

## Bisect

Binary search to find the commit that introduced a bug:

```bash
# Start bisect
git bisect start

# Mark current state as bad
git bisect bad

# Mark a known good commit
git bisect good v1.0.0

# Git checks out a middle commit — test it, then:
git bisect good   # if the bug is NOT present
git bisect bad    # if the bug IS present

# Repeat until Git identifies the culprit
# Done — clean up
git bisect reset
```

### Automated Bisect

Run a script to test each commit automatically:

```bash
# Script should exit 0 for good, non-0 for bad
git bisect start HEAD v1.0.0
git bisect run npm test
```

## Reflog

Recover lost commits and undo mistakes:

```bash
# View recent history of HEAD movements
git reflog

# View reflog for a specific branch
git reflog show feature/auth

# Recover a lost commit (after reset --hard, branch deletion, etc.)
git reflog
# Find the SHA of the lost commit
git checkout -b recovered-branch abc123

# Undo an accidental rebase
git reflog
# Find the SHA of HEAD before the rebase
git reset --hard HEAD@{5}
```

### Common Recovery Scenarios

| Lost Because | Recovery |
|---|---|
| `git reset --hard` | `git reflog` → `git reset --hard <sha>` |
| Deleted branch | `git reflog` → `git checkout -b <branch> <sha>` |
| Bad rebase | `git reflog` → `git reset --hard HEAD@{n}` |
| Amended wrong commit | `git reflog` → `git reset --soft HEAD@{1}` |

Reflog entries expire after 90 days (30 for unreachable commits). Act promptly.
