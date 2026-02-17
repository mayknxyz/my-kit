# /mykit.issue.view

Quick view of a GitHub issue.

## Usage

```
/mykit.issue.view <number>
```

**Args**: Issue number (required).

## Implementation

### Step 1: Prerequisites

Verify the environment is ready:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
gh auth status 2>/dev/null
git remote get-url origin 2>/dev/null
```

**If any check fails**, display the corresponding error and stop (same as `/mykit.issue.create`).

### Step 2: Parse issue number

Extract the issue number from `$ARGUMENTS`. The number may be prefixed with `#` (e.g., `#42` or `42`).

**If no issue number provided**, display error and stop:

```
**Error**: Issue number required. Usage: `/mykit.issue.view <number>`
```

### Step 3: Display issue

```bash
gh issue view {NUMBER}
```

**If issue not found**, display error and stop:

```
**Error**: Issue #{NUMBER} not found.
```

Display the output directly — `gh issue view` provides a well-formatted display including title, state, author, labels, assignees, milestone, and body.

## Error Handling

| Error | Message |
|-------|---------|
| No issue number | `Issue number required. Usage: /mykit.issue.view <number>` |
| Issue not found | `Issue #{NUMBER} not found.` |
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.issue.edit` | Edit the viewed issue |
| `/mykit.issue.list` | List all issues |
| `/mykit.review.issues` | Analytical deep-dive on issues |
