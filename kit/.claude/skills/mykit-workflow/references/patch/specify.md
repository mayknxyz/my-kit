<!-- Patch mode: optional lightweight specification workflow -->

## Patch Mode Specification

Create an optional lightweight feature specification from a GitHub issue or via guided conversation.

In Patch mode, creating a specification is optional. For simple fixes, skip directly to `/mykit.implement`. For complex patches that benefit from documentation, use this guided spec workflow.

### Step 1: Check Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display error and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `hasCreateAction`: always true (CRUD routing handled by command router)
- `hasNoIssueFlag`: true if `--no-issue` is present
- `hasForceFlag`: true if `--force` is present

### Step 3: Get Current Branch and Extract Issue Number

Get the current branch name:

```bash
git rev-parse --abbrev-ref HEAD
```

Extract the issue number from the branch name using pattern `^([0-9]+)-`:
- **If branch matches pattern** (e.g., `042-feature-name`):
  - Extract issue number (e.g., `42`)
  - Set `issueNumber` to the extracted number
  - Set `isFeatureBranch = true`
- **If branch does NOT match pattern** (e.g., `main`, `develop`):
  - Set `issueNumber = null`
  - Set `isFeatureBranch = false`

### Step 4: Validate Issue Requirement (with Auto-Branch)

**If `hasNoIssueFlag` is false AND `issueNumber` is null**:

First, check the auto-branch config:

```bash
source $HOME/.claude/skills/mykit/references/scripts/utils.sh
AUTO_CREATE_BRANCH=$(get_config_field_or_default ".specify.autoCreateBranch" "true")
```

**If `AUTO_CREATE_BRANCH` is "true"**:

1. Check if an issue number was provided in the command arguments (e.g., `github issue #48`). If so, extract and use it. Otherwise, use `AskUserQuestion` to prompt:
   - header: "Issue Number"
   - question: "You're on the default branch. Which GitHub issue is this spec for? (Enter the issue number, e.g., 48)"
   - options:
     1. label: "Enter number", description: "Provide a GitHub issue number to link this spec to"

2. Store the response as `issueNumber`.

3. Fetch the issue title for branch naming:
   ```bash
   ISSUE_TITLE=$(gh issue view $issueNumber --json title --jq '.title' 2>/dev/null || echo "")
   ```

4. Generate a branch slug from the issue title:
   - If title available: lowercase, replace spaces/special chars with hyphens, keep 2-4 meaningful words
   - If title unavailable: use `AskUserQuestion` to prompt for a short branch name (2-4 words)

5. Create the feature branch and spec directory:
   ```bash
   $HOME/.claude/skills/mykit/references/scripts/create-new-feature.sh --json --number $issueNumber --short-name "$slug" "$ISSUE_TITLE"
   ```
   Parse the JSON output to get `BRANCH_NAME` and `SPEC_FILE`.

6. The script switches to the new branch automatically. Update variables:
   - Set `isFeatureBranch = true`
   - Set `issueNumber` from the parsed output
   - Set the current branch to `BRANCH_NAME`
   - Continue to Step 5

**If `AUTO_CREATE_BRANCH` is "false"**:

Display error and stop:
```
**Error**: No issue selected.

You must be on a feature branch (e.g., `042-feature-name`) or use the `--no-issue` flag.

To select an issue: `/mykit.start`
To skip issue requirement: `/mykit.specify -c --no-issue`
```

### Step 5: Determine Spec Path

**If `hasNoIssueFlag` is true**:
- Spec path will be determined after guided conversation (uses slug from Q1 answer)
- Set `specPath = null` (to be determined later)

**If on a feature branch**:
- Set `specPath = specs/{branch}/spec.md` where `{branch}` is the current branch name

### Step 6: Check for Existing Spec

**If `specPath` is set AND file exists at that path**:

**If `hasForceFlag` is true**:
- Continue (will overwrite)

**If `hasForceFlag` is false AND `hasCreateAction` is true**:
- Use `AskUserQuestion` tool to prompt:
  - header: "Existing Spec"
  - question: "A spec file already exists at this location. What would you like to do?"
  - options:
    1. label: "Overwrite", description: "Replace the existing spec entirely"
    2. label: "Cancel", description: "Abort and keep the existing spec"

- If user selects "Cancel", display message and stop:
  ```
  Operation cancelled. Existing spec preserved.
  ```

### Step 7: Attempt GitHub Issue Extraction

**If `issueNumber` is not null**:

Attempt to fetch issue details:
```bash
gh issue view {issueNumber} --json body,title 2>/dev/null
```

**Handle results**:

- **If gh command fails** (GitHub CLI unavailable or not authenticated):
  - Set `ghAvailable = false`
  - Display warning:
    ```
    **Warning**: Unable to fetch GitHub issue details. Proceeding with guided conversation.
    ```
  - Continue to Step 8 (guided conversation)

- **If gh command succeeds**:
  - Parse JSON and extract `body` and `title`
  - Set `issueTitle = title`
  - Check body length:
    - **If body length >= 50 characters**: Attempt section extraction (Step 7a)
    - **If body length < 50 characters**: Continue to Step 8 (guided conversation)

#### Step 7a: Extract Sections from Issue Body

Search for common markdown headings and extract content:

**Summary/Description extraction**:
- Look for: `## Summary`, `## Description`, `## Overview`, `## What`
- Extract content until next `##` heading or end of body
- If not found, use first paragraph of body as summary

**Problem extraction**:
- Look for: `## Problem`, `## Why`, `## Motivation`, `## Background`
- Extract content until next `##` heading or end of body
- If not found, set to empty (will prompt in conversation)

**Acceptance Criteria extraction**:
- Look for: `## Acceptance Criteria`, `## Criteria`, `## Done when`, `## Checklist`
- Extract content until next `##` heading or end of body
- If not found, set to empty (will prompt in conversation)

**After extraction**:
- Set `summary` to extracted summary content
- Set `problem` to extracted problem content (or empty)
- Set `acceptanceCriteria` to extracted criteria content (or empty)
- Set `contentSource = "issue"` if at least summary was extracted
- If no sections found but body >= 50 chars, use full body as summary

### Step 8: Guided Conversation (if needed)

**Trigger conversation if**:
- `issueNumber` is null (--no-issue mode), OR
- GitHub issue body < 50 characters, OR
- No sections could be extracted from issue body

**Question 1: Summary**

Use `AskUserQuestion` tool:
- header: "Spec: Summary"
- question: "What is this feature/change about?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `summary`.

**Question 2: Problem**

Use `AskUserQuestion` tool:
- header: "Spec: Problem"
- question: "What problem does it solve?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `problem`.

**Question 3: Acceptance Criteria**

Use `AskUserQuestion` tool:
- header: "Spec: Criteria"
- question: "What should be true when done? (List the key criteria)"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `acceptanceCriteria`.

Set `contentSource = "conversation"`

### Step 9: Generate Ad-hoc Spec Path (if needed)

**If `hasNoIssueFlag` is true AND `specPath` is null**:
- Generate a slug from the summary (first 30 chars, lowercase, spaces to hyphens)
- Set `specPath = specs/adhoc-{slug}/spec.md`
- Create the directory if it doesn't exist

### Step 10: Format Spec Content

Generate the spec content using the lite template structure:

```markdown
# Feature Specification: {featureName}

**Feature Branch**: `{branch}`
**Created**: {currentDate}
**Status**: Draft
**GitHub Issue**: {issueLink or "N/A (ad-hoc)"}

## Overview

{summary}

## Problem

{problem}

## User Scenarios

### User Story 1 - Primary Flow (Priority: P1)

{summary}

**Acceptance Scenarios**:

{acceptanceCriteria formatted as Given/When/Then or bullet list}

## Requirements

### Functional Requirements

- **FR-001**: {derived from acceptance criteria}

## Success Criteria

- **SC-001**: {derived from acceptance criteria}
```

Where:
- `featureName` = issue title if available, otherwise derived from summary
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format
- `issueLink` = `[#N](https://github.com/{owner}/{repo}/issues/N)` or "N/A (ad-hoc)"

### Step 11: Preview or Execute

**If `hasCreateAction` is false (Preview Mode — deprecated, handled by router)**:

Display the spec content with a preview header:

```
## PREVIEW - Proposed Specification

{formatted spec content from Step 10}

---

**Note**: This is a preview. No files have been created.

To save this specification, run: `/mykit.specify -c`
```

Stop execution here.

**If `hasCreateAction` is true (Execute Mode)**:

1. Create the spec directory if it doesn't exist
2. Write the spec content to `specPath`
3. Display confirmation:

```
**Spec created successfully!**

**File**: {specPath}
**Source**: {contentSource === "issue" ? "Extracted from GitHub issue" : "Guided conversation"}

Next step: `/mykit.plan -c` to create an implementation plan, or `/mykit.implement` to start implementing directly.
```
