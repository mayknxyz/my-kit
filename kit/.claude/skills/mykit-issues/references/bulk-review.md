# /mykit.review.issues audit — Bulk Review

Bulk audit of all open GitHub issues. Categorizes issues, detects duplicates, analyzes staleness, and computes health metrics.

**This operation is read-only — it never modifies issues.**

## Usage

```
/mykit.review.issues audit
/mykit.review.issues bulk
/mykit.review.issues all
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

### Step 2: Fetch All Open Issues

```bash
gh issue list --state open --json number,title,body,labels,assignees,author,createdAt,updatedAt,comments,milestone --limit 100
```

If no open issues, display:

```
No open issues found. Nothing to audit.
```

Stop here.

### Step 3: Fetch Repo Labels

```bash
gh label list --json name,description,color --limit 100
```

### Step 4: Categorize Issues

Categorize each issue based on its labels and content keywords:

| Category | Label indicators | Content indicators |
|----------|-----------------|-------------------|
| Bug | bug, defect, error | "error", "crash", "broken", "fix", "fails", "doesn't work" |
| Feature | feature, enhancement | "add", "implement", "support", "new", "proposal" |
| Docs | documentation, docs | "document", "readme", "typo in docs", "guide" |
| Question | question, help wanted | "how to", "is it possible", "why does" |
| Maintenance | chore, maintenance, tech debt | "refactor", "cleanup", "update dependency", "migrate" |
| Performance | performance, slow | "slow", "performance", "optimize", "memory", "latency" |
| Security | security, vulnerability | "vulnerability", "CVE", "security", "auth", "XSS", "injection" |
| Uncategorized | (none matched) | (none matched) |

Assign the best-fit category. If multiple match, prefer the category with the strongest signal (label > content keywords).

### Step 5: Detect Duplicates

For each pair of issues, compute a similarity score:

1. **Title similarity** (weight: 60%): Extract significant words from each title, compute overlap ratio
2. **Body similarity** (weight: 40%): Extract significant words from each body (first 500 chars), compute overlap ratio

Skip common stop words: the, is, a, an, in, to, for, and, or, of, it, this, that, with, on, at, by, from, as, be, are, was, were, has, have, had, not, but, do, does, did, will, would, could, should, can, may, if, then, than, so, no, up, out, about, into, over, after, its

**Similarity threshold**: Flag pairs with combined score >50% as potential duplicates.

### Step 6: Staleness Analysis

Bucket each issue by `updatedAt`:

| Bucket | Threshold |
|--------|-----------|
| Active | Updated within 7 days |
| Aging | Updated 8–30 days ago |
| Stale | Updated 31–90 days ago |
| Very stale | Updated 91–180 days ago |
| Abandoned | Updated 180+ days ago |

### Step 7: Compute Health Metrics

| Metric | Calculation |
|--------|-------------|
| Unassigned % | Issues with no assignees / total |
| Unlabeled % | Issues with no labels / total |
| No-milestone % | Issues with no milestone / total |
| Low-engagement % | Issues with 0 comments / total |
| Average age | Mean days since creation |
| Median age | Median days since creation |

### Step 8: Display Bulk Review Report

```
## Issue Bulk Review

**Repository**: {owner/repo}
**Open issues**: {count}
**Date**: {today}

### Health Overview

| Metric | Value | Status |
|--------|-------|--------|
| Unassigned | {count} ({pct}%) | {good (<20%) / warning (20-50%) / critical (>50%)} |
| Unlabeled | {count} ({pct}%) | {good / warning / critical} |
| No milestone | {count} ({pct}%) | {good / warning / critical} |
| Low engagement | {count} ({pct}%) | {good / warning / critical} |
| Average age | {days} days | — |
| Median age | {days} days | — |

### Category Breakdown

| Category | Count | % |
|----------|-------|---|
| Bug | {count} | {pct}% |
| Feature | {count} | {pct}% |
| Docs | {count} | {pct}% |
| Question | {count} | {pct}% |
| Maintenance | {count} | {pct}% |
| Performance | {count} | {pct}% |
| Security | {count} | {pct}% |
| Uncategorized | {count} | {pct}% |

### Freshness Distribution

| Bucket | Count | Issues |
|--------|-------|--------|
| Active | {count} | {#numbers} |
| Aging | {count} | {#numbers} |
| Stale | {count} | {#numbers} |
| Very stale | {count} | {#numbers} |
| Abandoned | {count} | {#numbers} |

### Potential Duplicates

{For each duplicate pair}:
- **#{a}** "{title_a}" ↔ **#{b}** "{title_b}" — {similarity}% overlap

{If no duplicates}: No potential duplicates detected.

### Stale Issues (90+ days)

| # | Title | Last Updated | Age |
|---|-------|-------------|-----|
| {number} | {title} | {updatedAt} | {days} days |

### Unlabeled Issues

| # | Title | Created |
|---|-------|---------|
| {number} | {title} | {createdAt} |

### Unassigned Issues

| # | Title | Created |
|---|-------|---------|
| {number} | {title} | {createdAt} |

### All Issues

| # | Title | Category | Freshness | Labels | Assignees |
|---|-------|----------|-----------|--------|-----------|
| {number} | {title} | {category} | {bucket} | {labels} | {assignees} |

### Top 5 Recommendations

{Actionable recommendations based on the analysis, e.g.:}
1. {Close/triage the N abandoned issues}
2. {Add labels to N unlabeled issues}
3. {Review N potential duplicate pairs}
4. {Assign N unassigned issues}
5. {Add milestones to prioritize the backlog}
```

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
- Limited to 100 open issues for practical analysis
- Duplicate detection is pairwise O(n²) — with 100 issues that's 4,950 comparisons, which is manageable
- Category assignment is best-effort based on labels and keywords
- Health metric thresholds (good/warning/critical) are guidelines, not prescriptive
