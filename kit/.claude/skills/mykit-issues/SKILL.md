---
name: mykit-issues
description: My Kit issue analysis — handles triage, deep-dive, and bulk review of GitHub issues.
---

# My Kit Issues

Handles read-only GitHub issue analysis: triage, single-issue deep-dive, and bulk review. Auto-activates when the user expresses intent to review, triage, or analyze GitHub issues.

## Trigger Keywords

- **triage**: "triage issues", "review issues", "check issues", "analyze issues", "issue triage"
- **deep-dive**: "check issue #N", "analyze issue N", "look at issue N", "deep dive issue"
- **bulk-review**: "audit issues", "bulk review", "review all issues", "issue health"

## Step Identification

| Step | Keywords | Description |
|------|----------|-------------|
| `triage` | triage, review issues, check issues | Review and triage open issues |
| `deep-dive` | check issue, analyze issue, issue #N | Deep-dive analysis of a single issue |
| `bulk-review` | audit issues, bulk review, all issues | Bulk audit of all open issues |

## Routing Logic

### 1. Identify Step

Map user intent using argument-based routing:

- **No arguments** → `triage`
- **Numeric argument** (e.g., `42`, `#42`) → `deep-dive`
- **Keyword argument** (`audit`, `bulk`, `all`) → `bulk-review`
- **`triage`** → `triage`

### 2. Check Prerequisites

Before executing any step, verify:

```bash
# In a git repository
git rev-parse --git-dir 2>/dev/null

# gh CLI installed
command -v gh

# Authenticated
gh auth status
```

### 3. Load Reference File

| Step | Reference |
|------|-----------|
| triage | `references/triage.md` |
| deep-dive | `references/deep-dive.md` |
| bulk-review | `references/bulk-review.md` |

**Load only the one reference file needed per invocation.**

### 4. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. Each reference contains the complete workflow:

- **triage.md**: Fetch open issues, analyze completeness/clarity/staleness, detect duplicates, suggest labels, display triage report
- **deep-dive.md**: Fetch single issue, search codebase for related files, assess validity/complexity, suggest implementation approach
- **bulk-review.md**: Fetch all open issues, categorize, detect duplicates, analyze staleness, compute health metrics, display audit report

## Reference Files

- `references/triage.md` — Review and triage open issues
- `references/deep-dive.md` — Single issue deep-dive analysis
- `references/bulk-review.md` — Bulk audit of all open issues
