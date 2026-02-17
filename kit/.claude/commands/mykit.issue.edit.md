# /mykit.issue.edit

Edit an existing GitHub issue.

## Usage

```
/mykit.issue.edit <number> [flags]
```

**Args**: Issue number (required). Optional flags: `--title`, `--body`, `--add-label`, `--remove-label`, `--add-assignee`, `--remove-assignee`, `--milestone`.

## Implementation

### Step 1: Prerequisites

Verify the environment is ready:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
gh auth status 2>/dev/null
git remote get-url origin 2>/dev/null
```

**If any check fails**, display the corresponding error and stop (same as `/mykit.issue.create`).

### Step 2: Parse arguments

Extract the issue number from `$ARGUMENTS`. The number may be prefixed with `#` (e.g., `#42` or `42`).

**If no issue number provided**, display error and stop:

```
**Error**: Issue number required. Usage: `/mykit.issue.edit <number>`
```

Parse any optional flags from the remaining arguments.

### Step 3: Fetch current issue state

```bash
gh issue view {NUMBER} --json number,title,body,labels,assignees,milestone,state,url
```

**If issue not found**, display error and stop:

```
**Error**: Issue #{NUMBER} not found.
```

Display the current state:

```
**Issue #{NUMBER}**: {TITLE}

**State**: {STATE}
**Labels**: {LABELS}
**Assignees**: {ASSIGNEES}
**Milestone**: {MILESTONE}
```

### Step 4: Determine edits

**If flags were provided**: Apply those edits directly.

**If no flags were provided**: Use `AskUserQuestion`:

- header: "Edit"
- question: "What would you like to edit on issue #{NUMBER}?"
- options:
  1. label: "Title", description: "Change the issue title"
  2. label: "Labels", description: "Add or remove labels"
  3. label: "Assignees", description: "Add or remove assignees"
  4. label: "Body", description: "Update the issue body"

Then gather the new values interactively based on selection.

**For label edits**: Read the canonical label list from `$HOME/.claude/skills/mykit/references/labels.md`. Only labels defined there are allowed — never create new labels. Present canonical labels as selectable options.

### Step 5: Apply edits

```bash
gh issue edit {NUMBER} {FLAGS}
```

Where `{FLAGS}` are the appropriate `gh issue edit` flags (e.g., `--title "..."`, `--add-label "..."`, `--remove-label "..."`, `--add-assignee "..."`, `--remove-assignee "..."`, `--milestone "..."`).

### Step 6: Display updated state

```bash
gh issue view {NUMBER} --json number,title,labels,assignees,milestone,state,url
```

```
**Issue #{NUMBER} updated.**

**Title**: {TITLE}
**Labels**: {LABELS}
**Assignees**: {ASSIGNEES}
**URL**: {URL}
```

## Error Handling

| Error | Message |
|-------|---------|
| No issue number | `Issue number required. Usage: /mykit.issue.edit <number>` |
| Issue not found | `Issue #{NUMBER} not found.` |
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |
| Edit fails | Display `gh` error output |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.issue.view` | View issue details before/after editing |
| `/mykit.issue.create` | Create a new issue |
| `/mykit.review.issues` | Analytical deep-dive on issues |
