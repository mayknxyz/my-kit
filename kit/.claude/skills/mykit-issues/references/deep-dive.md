# /mykit.review.issues {number} — Deep Dive

Deep-dive analysis of a single GitHub issue. Searches the codebase for related files, assesses validity and complexity, and suggests an implementation approach.

**This operation is read-only — it never modifies issues.**

## Usage

```
/mykit.review.issues 42
/mykit.review.issues #42
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

### Step 2: Parse Issue Number

Extract the issue number from `$ARGUMENTS`:
- Strip leading `#` if present
- Validate it's a positive integer

If invalid, display error and stop:

```
**Error**: Invalid issue number '{arg}'. Usage: `/mykit.review.issues 42` or `/mykit.review.issues #42`
```

### Step 3: Fetch Issue Details

```bash
gh issue view {number} --json number,title,body,labels,assignees,author,createdAt,updatedAt,comments,milestone,state
```

If the issue doesn't exist or is not accessible, display error and stop:

```
**Error**: Issue #{number} not found or not accessible.
```

### Step 4: Extract Keywords

From the issue title and body, extract:
- **Technical terms**: function names, class names, component names
- **File paths**: any paths mentioned (e.g., `src/lib/auth.ts`)
- **Error messages**: quoted errors, stack traces, error codes
- **Domain terms**: significant nouns and technical vocabulary

Skip common stop words and generic terms.

### Step 5: Search Codebase

For each extracted keyword, search the codebase using Grep:
- Search for file path references
- Search for function/class/component names
- Search for error message strings

Collect the set of related files, ranked by number of keyword matches.

Display up to 10 most relevant files.

### Step 6: Assess Issue

#### Validity

- **Still relevant**: Issue describes a problem that exists in current code
- **Already resolved**: Related code has been changed/removed since issue was filed
- **Outdated**: References deprecated APIs, removed features, or old patterns

#### Complexity

Based on number of related files and scope of changes implied:

| Level | Criteria |
|-------|----------|
| Trivial | 1 file, minor change (typo, config tweak) |
| Small | 1–2 files, straightforward change |
| Medium | 3–5 files, moderate logic changes |
| Large | 6+ files or architectural changes |

#### Completeness

- **Well-defined**: Clear problem, clear expected behavior, actionable
- **Under-specified**: Missing reproduction steps, unclear scope, or vague requirements
- **Needs discussion**: Requires design decisions or stakeholder input

### Step 7: Suggest Implementation Approach

Based on the codebase analysis:
- List affected files with brief description of needed changes
- Suggest order of implementation
- Note any dependencies or prerequisites
- Flag potential risks or side effects

### Step 8: Find Related Issues

```bash
gh issue list --state open --json number,title,labels --limit 50
```

Compare the current issue's keywords and labels against other open issues. List issues with significant overlap as related.

### Step 9: Display Deep-Dive Report

```
## Issue #{number} — Deep Dive

### Issue Details

| Field | Value |
|-------|-------|
| Title | {title} |
| Author | {author} |
| State | {state} |
| Labels | {labels} |
| Assignees | {assignees} |
| Milestone | {milestone} |
| Created | {createdAt} |
| Updated | {updatedAt} |
| Comments | {comment count} |

### Description

{issue body, summarized if very long}

### Assessment

| Aspect | Rating | Notes |
|--------|--------|-------|
| Validity | {still relevant / already resolved / outdated} | {explanation} |
| Complexity | {trivial / small / medium / large} | {file count, scope} |
| Completeness | {well-defined / under-specified / needs discussion} | {what's missing} |

### Codebase Analysis

**Related files** (by keyword match):

| File | Relevance | Keywords Matched |
|------|-----------|-----------------|
| {path} | {high/medium/low} | {keywords} |

### Suggested Implementation

{Ordered list of changes with affected files}

### Related Issues

| # | Title | Overlap |
|---|-------|---------|
| {number} | {title} | {shared keywords/labels} |

### Comments Summary

{Summary of discussion thread, if any comments exist}

### Key Recommendations

{3–5 actionable recommendations based on the deep-dive analysis, e.g.:}
1. {Add missing reproduction steps / acceptance criteria to clarify scope}
2. {Start with [specific file] — it has the highest relevance and lowest risk}
3. {Split into smaller issues if complexity is Large}
4. {Close as outdated if the related code has been removed/refactored}
5. {Link to related issue #N and consider resolving together}
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository." |
| gh CLI missing | "GitHub CLI (`gh`) is not installed." |
| Not authenticated | "Not authenticated with GitHub. Run `gh auth login` first." |
| Invalid issue number | "Invalid issue number '{arg}'." |
| Issue not found | "Issue #{number} not found or not accessible." |

## Notes

- This operation is **read-only** — it never creates, updates, or closes issues
- Codebase search uses Grep tool, not shell grep
- Keyword extraction is best-effort — it may miss domain-specific terms
- Complexity assessment is an estimate based on file count and scope indicators
