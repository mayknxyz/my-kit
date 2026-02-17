# /mykit.review.issues — Triage

Review and triage open GitHub issues. Analyzes completeness, clarity, staleness, and potential duplicates. Suggests labels from the canonical label list.

**This operation is read-only — it never modifies issues.**

## Usage

```
/mykit.review.issues
/mykit.review.issues triage
```

## User Input

```text
$ARGUMENTS
```

## Implementation

### Step 1: Check Prerequisites

```bash
# In a git repository
git rev-parse --git-dir 2>/dev/null
```

If not in a git repo, display error and stop:

```
**Error**: Not in a git repository.
```

```bash
# gh CLI installed
command -v gh
```

If `gh` is not installed, display error and stop:

```
**Error**: GitHub CLI (`gh`) is not installed. Install it from https://cli.github.com
```

```bash
# Authenticated
gh auth status
```

If not authenticated, display error and stop:

```
**Error**: Not authenticated with GitHub. Run `gh auth login` first.
```

```bash
# Has a GitHub remote
gh repo view --json nameWithOwner -q .nameWithOwner
```

If no GitHub remote, display error and stop:

```
**Error**: No GitHub remote found for this repository.
```

### Step 2: Fetch Open Issues

```bash
gh issue list --state open --json number,title,body,labels,assignees,author,createdAt,updatedAt,comments,milestone --limit 50
```

If no open issues, display:

```
No open issues found. Nothing to triage.
```

Stop here.

### Step 3: Load Canonical Labels

Read the canonical label list from `$HOME/.claude/skills/mykit/references/labels.md`. Only labels defined there are allowed — never suggest or apply labels outside this list.

### Step 4: Analyze Each Issue

For each issue, assess:

#### Completeness

- **Has body**: Does the issue have a non-empty body?
- **Has sections**: Does the body contain headings or structured sections?
- **Reproduction steps**: For bugs, does it include steps to reproduce?
- Score: complete / partial / minimal

#### Clarity

- **Clear problem statement**: Is the problem or request clearly stated?
- **Clear expected outcome**: Is the desired outcome defined?
- Score: clear / unclear / ambiguous

#### Staleness

Based on `updatedAt`:

| Bucket | Threshold |
|--------|-----------|
| Fresh | Updated within 7 days |
| Aging | Updated 8–30 days ago |
| Stale | Updated 31–90 days ago |
| Very stale | Updated 90+ days ago |

#### Duplicate Detection

Compare each pair of issues by keyword overlap in titles:

- Extract significant words (skip common stop words like "the", "is", "a", "an", "in", "to", "for", "and", "or", "bug", "feature", "request", "issue")
- Flag pairs with >50% keyword overlap as potential duplicates

### Step 5: Suggest Labels

For each unlabeled issue, suggest labels from the canonical label list based on:

- Keywords in title and body matched against the auto-detection keywords table
- Issue type (bug report, feature request, question, documentation)
- Domain indicators (e.g., file paths, technology names)

Only suggest labels from the canonical list — never suggest labels outside it.

### Step 6: Display Triage Report

```
## Issue Triage Report

**Repository**: {owner/repo}
**Open issues**: {count}
**Date**: {today}

### Summary

| Metric | Count |
|--------|-------|
| Total open | {count} |
| Complete | {count} |
| Partial | {count} |
| Minimal | {count} |
| Fresh | {count} |
| Aging | {count} |
| Stale | {count} |
| Very stale | {count} |
| Unlabeled | {count} |
| Unassigned | {count} |
| Potential duplicates | {count pairs} |

### Per-Issue Analysis

| # | Title | Completeness | Clarity | Freshness | Labels | Attention |
|---|-------|-------------|---------|-----------|--------|-----------|
| {number} | {title} | {score} | {score} | {bucket} | {existing or suggested} | {flags} |

### Attention Items

#### Potential Duplicates

{List pairs of issues that may be duplicates with their keyword overlap}

#### Stale Issues (90+ days)

{List very stale issues with last update date}

#### Minimal Issues (need more detail)

{List issues with minimal completeness score}

#### Suggested Labels

{For each unlabeled issue, show suggested labels from repo's label set}

### Recommendations

Generate 3-7 prioritized, actionable recommendations based on the triage findings. Each recommendation must include the specific issue numbers and a concrete action. Always include recommendations for:

1. **Stale issues** (if any): Close, reprioritize, or request updates — list issue numbers
2. **Unlabeled issues** (if any): Suggest specific labels for each — list issue numbers and labels
3. **Minimal/ambiguous issues** (if any): Request detail or clarify — list issue numbers
4. **Duplicate candidates** (if any): Close the less detailed duplicate — list pairs
5. **Unassigned issues** (if any): Self-assign or delegate — list issue numbers
6. **Completed issues still open** (if any): Cross-reference with git history/commits and flag for closure — list issue numbers
7. **Related issues that could be grouped** (if any): Suggest milestones or batching — list issue numbers

Skip any category with zero matches.
```

## Bulk Actions

After displaying the triage report, if the user asks to act on recommendations (e.g., "apply", "close stale", "label all", "assign all"), execute the requested actions using `gh` CLI commands. Common patterns:

- **Close issues**: `gh issue close {number} --reason {completed|"not planned"} --comment "{reason}"`
- **Add labels**: `gh issue edit {number} --add-label "{label}"`
- **Self-assign**: `gh issue edit {number} --add-assignee @me`
- **Close duplicates**: `gh issue close {number} --reason "not planned" --comment "Duplicate of #{other}"`

These actions require user confirmation — never auto-execute them as part of the triage report itself.

## Output Formatting

- Replace em dashes in issue titles with regular hyphens for consistency with project style
- Truncate long titles to 60 characters in the per-issue table

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository." |
| gh CLI missing | "GitHub CLI (`gh`) is not installed." |
| Not authenticated | "Not authenticated with GitHub. Run `gh auth login` first." |
| No remote | "No GitHub remote found for this repository." |
| API rate limit | "GitHub API rate limit reached. Try again later." |

## Notes

- This operation is **read-only** — it never creates, updates, or closes issues
- Limited to 50 open issues to keep per-issue analysis manageable
- Duplicate detection uses simple keyword overlap — it flags candidates, not confirmed duplicates
- Label suggestions only use labels from the canonical list (`$HOME/.claude/skills/mykit/references/labels.md`)
