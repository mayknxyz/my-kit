# /mykit.issue.create

Create a GitHub issue from the current conversation context.

## Usage

```
/mykit.issue.create
```

## Implementation

### Step 1: Prerequisites

Verify the environment is ready:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

**If not a git repo**, display error and stop:

```
**Error**: Not inside a git repository.
```

```bash
gh auth status 2>/dev/null
```

**If not authenticated**, display error and stop:

```
**Error**: Not authenticated with GitHub CLI. Run `gh auth login` first.
```

```bash
git remote get-url origin 2>/dev/null
```

**If no remote**, display error and stop:

```
**Error**: No `origin` remote configured. Add a GitHub remote first.
```

### Step 2: Gather issue content

Summarize the current conversation to draft an issue title and body:

- **Title**: A concise summary of the feature, bug, or task being discussed
- **Body**: A structured summary including context, requirements, and any relevant details from the conversation or plan discussion

Format the body in markdown with appropriate headings (e.g., `## Context`, `## Requirements`, `## Notes`).

### Step 3: Confirm title and select labels

Read the canonical label list from `$HOME/.claude/skills/mykit/references/labels.md`. Only labels defined there are allowed — never create new labels.

Auto-detect relevant labels by matching keywords from the conversation content against the auto-detection keywords table in the canonical list (e.g., discussion about accessibility → `a11y`, bug report → `bug`, new feature → `enhancement`).

Use `AskUserQuestion`:

- header: "Issue"
- question: "Create this issue? Title: \"{DRAFT_TITLE}\""
- options:
  1. label: "Create as-is", description: "Create with auto-detected labels: {matched_labels}"
  2. label: "Edit title", description: "Modify the title before creating"
  3. label: "Pick labels", description: "Manually select labels from canonical list"
  4. label: "Cancel", description: "Abort without creating"

**If "Cancel"**: Display `Issue creation cancelled.` and stop.

**If "Edit title"**: Use `AskUserQuestion` to get the new title, then continue.

**If "Pick labels"**: Use `AskUserQuestion` with the canonical labels as options (multiSelect), then continue.

### Step 4: Create the issue

```bash
gh issue create --title "{TITLE}" --body "{BODY}" --assignee @me --label "{LABELS}"
```

If no labels were selected or matched, omit the `--label` flag.

### Step 5: Display success

```
**Issue created**: #{NUMBER} — {TITLE}

**URL**: {ISSUE_URL}
**Labels**: {LABELS}
**Assignee**: @me

**Next step**: `/mykit.specify {NUMBER}`
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |
| No remote | `No origin remote configured. Add a GitHub remote first.` |
| Canonical label file missing | Display error: `Canonical label list not found at $HOME/.claude/skills/mykit/references/labels.md` |
| Issue creation fails | Display `gh` error output |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.specify` | Recommended next step after issue creation |
| `/mykit.issue.view` | View the created issue |
| `/mykit.issue.edit` | Edit the issue after creation |
| `/mykit.review.issues` | Analytical deep-dive on issues |
