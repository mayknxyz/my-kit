# /mykit.label.sync

Enforce the canonical label set on the current repository.

## Usage

```
/mykit.label.sync
```

## Implementation

### Step 1: Prerequisites

Verify the environment is ready:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
gh auth status 2>/dev/null
git remote get-url origin 2>/dev/null
```

**If any check fails**, display the corresponding error and stop (same as `/mykit.issue.create`).

### Step 2: Load canonical labels

Read the canonical label list from `$HOME/.claude/skills/mykit/references/labels.md`.

**If file not found**, display error and stop:

```
**Error**: Canonical label list not found at `$HOME/.claude/skills/mykit/references/labels.md`.
```

### Step 3: Fetch repo labels

```bash
gh label list --json name,description,color --limit 100
```

### Step 4: Diff labels

Compare the repo's labels against the canonical list:

- **Missing**: Labels in the canonical list but not in the repo
- **Extra**: Labels in the repo but not in the canonical list
- **Present**: Labels that exist in both

Display the diff:

```
## Label Sync — {owner/repo}

### Status

| Category | Count | Labels |
|----------|-------|--------|
| Present | {count} | {comma-separated names} |
| Missing | {count} | {comma-separated names} |
| Extra | {count} | {comma-separated names} |
```

**If no missing and no extra labels**, display:

```
Labels are in sync. Nothing to do.
```

Skip to Step 7.

### Step 5: Add missing labels

**If missing labels exist**, create them:

```bash
gh label create "{name}" --description "{description}" --force
```

Use the descriptions and colors from the canonical list.

Display each label as it's created:

```
Created: `{name}` — {description}
```

### Step 6: Handle extra labels

**If extra labels exist**, prompt for each one using `AskUserQuestion`:

- header: "Extra"
- question: "Label `{name}` is not in the canonical list ({N} issues use it). What should we do?"
- options:
  1. label: "Delete", description: "Remove this label from the repo (will be stripped from issues)"
  2. label: "Keep", description: "Leave it — it's repo-specific and intentional"

Check how many issues use the label before prompting:

```bash
gh issue list --label "{name}" --state all --json number --jq 'length'
```

**If "Delete"**:

```bash
gh label delete "{name}" --yes
```

Display: `Deleted: \`{name}\``

**If "Keep"**: Display: `Kept: \`{name}\` (not in canonical list)`

### Step 7: Scan and re-label issues

After syncing label definitions, scan open issues for labeling opportunities.

```bash
gh issue list --state open --json number,title,body,labels --limit 100
```

For each issue, use the auto-detection keywords table from the canonical list to match labels:

- **Unlabeled issues**: Suggest labels based on title and body keywords
- **Labeled issues**: Suggest additional labels that are missing but match keywords (do not remove existing labels)

**If no suggestions**, display:

```
All open issues have appropriate labels. Nothing to suggest.
```

Stop here.

**If suggestions exist**, display them:

```
### Suggested Label Changes

| # | Title | Current Labels | Suggested Additions |
|---|-------|---------------|-------------------|
| {number} | {title} | {current labels or "none"} | {suggested labels} |
```

Use `AskUserQuestion`:

- header: "Apply"
- question: "Apply suggested labels to {N} issues?"
- options:
  1. label: "Apply all", description: "Add all suggested labels"
  2. label: "Review each", description: "Confirm each issue individually"
  3. label: "Skip", description: "Don't change any issues"

**If "Apply all"**: Apply all suggestions:

```bash
gh issue edit {NUMBER} --add-label "{label1},{label2}"
```

**If "Review each"**: For each issue, use `AskUserQuestion`:

- header: "#{number}"
- question: "Add {suggested labels} to #{number} \"{title}\"?"
- options:
  1. label: "Yes", description: "Add the suggested labels"
  2. label: "Skip", description: "Leave this issue as-is"

**If "Skip"**: Display `Skipped issue labeling.`

### Step 8: Display summary

```
## Label Sync Complete

**Labels created**: {count}
**Labels deleted**: {count}
**Labels kept (extra)**: {count}
**Issues updated**: {count}
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |
| No remote | `No origin remote configured. Add a GitHub remote first.` |
| Canonical list missing | `Canonical label list not found at $HOME/.claude/skills/mykit/references/labels.md` |
| Label create fails | Display `gh` error output, continue with remaining labels |
| Label delete fails | Display `gh` error output, continue with remaining labels |

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.issue.create` | Creates issues using canonical labels |
| `/mykit.issue.edit` | Edits issues with canonical label constraint |
| `/mykit.review.issues` | Analytical triage that suggests labels |
