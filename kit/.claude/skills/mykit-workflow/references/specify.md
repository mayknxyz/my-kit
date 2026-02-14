<!-- Specification workflow -->

## Specification

Create a lightweight feature specification from a GitHub issue or via guided conversation.

### Step 1: Load Branch Context

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

### Step 2: Parse Arguments and Resolve Issue Number

**Step 2.1**: Validate `$ARGUMENTS` is a positive integer using pattern `^\d+$`:
- **If valid** (e.g., `31`): Set `issueNumber` to that number
- **If empty**: Display error and stop:
  ```
  **Error**: Issue number required.

  Usage: /mykit.specify <issue-number>
  Example: /mykit.specify 31
  ```
- **If non-integer** (e.g., `gh#31`, `foo`): Display error and stop:
  ```
  **Error**: Invalid argument "{$ARGUMENTS}". Expected a number.

  Usage: /mykit.specify <issue-number>
  Example: /mykit.specify 31
  ```

**Step 2.2**: Determine if current branch is correct:
- **Correct branch**: `ISSUE_NUMBER` equals `issueNumber`
- **Wrong branch**: `ISSUE_NUMBER` differs from `issueNumber`
- **No feature branch**: `ISSUE_NUMBER` is empty

Set `needsNewBranch = true` if wrong branch or no feature branch. Otherwise `false`.

### Step 3: Auto-Create Branch (if needed)

**If `needsNewBranch` is false**: Skip to Step 4.

**If `needsNewBranch` is true**:

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
   - Continue to Step 4

### Step 4: Determine Spec Path

Set `specPath = specs/{branch}/spec.md` where `{branch}` is the current branch name.

### Step 5: Check for Existing Spec

**If file exists at `specPath`**:

Use `AskUserQuestion` tool to prompt:
  - header: "Existing Spec"
  - question: "A spec file already exists at this location. What would you like to do?"
  - options:
    1. label: "Overwrite", description: "Replace the existing spec entirely"
    2. label: "Cancel", description: "Abort and keep the existing spec"

- If user selects "Cancel", display message and stop:
  ```
  Operation cancelled. Existing spec preserved.
  ```

### Step 6: Attempt GitHub Issue Extraction

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
  - Continue to Step 7 (guided conversation)

- **If gh command succeeds**:
  - Parse JSON and extract `body` and `title`
  - Set `issueTitle = title`
  - Check body length:
    - **If body length >= 50 characters**: Attempt section extraction (Step 6a)
    - **If body length < 50 characters**: Continue to Step 7 (guided conversation)

#### Step 6a: Extract Sections from Issue Body

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

### Step 7: Review Issue Details

**If extraction succeeded** (at least `summary` is set):

Load and follow the instructions in `references/issue-review.md`. This step:
1. Presents extracted details back to the user
2. Flags missing or vague sections
3. Provides specific recommendations
4. Asks user to accept, accept with recommendations, or clarify

After the review, `summary`, `problem`, and `acceptanceCriteria` may be updated.

### Step 8: Guided Conversation (if needed)

**Trigger conversation if**:
- GitHub issue body < 50 characters, OR
- No sections could be extracted from issue body, OR
- Sections are still empty after review

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

### Step 9: Format Spec Content

Generate the spec content using the lite template structure:

```markdown
# Feature Specification: {featureName}

**Feature Branch**: `{branch}`
**Created**: {currentDate}
**Status**: Draft
**GitHub Issue**: {issueLink}

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
- `featureName` = issue title from GitHub
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format
- `issueLink` = `[#N](https://github.com/{owner}/{repo}/issues/N)`

### Step 10: Write Spec

1. Create the spec directory if it doesn't exist
2. Write the spec content to `specPath`
3. Display confirmation:

```
**Spec created successfully!**

**File**: {specPath}
**Source**: {contentSource === "issue" ? "Extracted from GitHub issue" : "Guided conversation"}

Next step: `/mykit.plan` to create an implementation plan.
```
