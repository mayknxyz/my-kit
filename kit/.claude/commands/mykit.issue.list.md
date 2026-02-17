# /mykit.issue.list

Quick list of GitHub issues.

## Usage

```
/mykit.issue.list [filters]
```

**Args** (all optional): `--state open|closed|all`, `--label "..."`, `--assignee @me`.

## Implementation

### Step 1: Prerequisites

Verify the environment is ready:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
gh auth status 2>/dev/null
git remote get-url origin 2>/dev/null
```

**If any check fails**, display the corresponding error and stop (same as `/mykit.issue.create`).

### Step 2: Parse filters

Extract optional filters from `$ARGUMENTS`:

- `--state` → `open` (default), `closed`, or `all`
- `--label` → filter by label name
- `--assignee` → filter by assignee (e.g., `@me`)

If no arguments provided, default to listing open issues.

### Step 3: List issues

```bash
gh issue list {FILTERS}
```

Where `{FILTERS}` are the parsed flags (e.g., `--state closed --label "bug" --assignee @me`).

Display the output directly — `gh issue list` provides a table with issue number, title, labels, and last updated.

**If no issues found**, display:

```
No issues found matching the given filters.
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |
| No remote | `No origin remote configured. Add a GitHub remote first.` |
| Invalid filter | Display `gh` error output |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.issue.create` | Create a new issue |
| `/mykit.issue.view` | View a specific issue in detail |
| `/mykit.review.issues` | Analytical triage and deep-dive on issues |
