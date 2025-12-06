# /mykit.specify

Create a lightweight feature specification from a GitHub issue or via guided conversation.

## Usage

```
/mykit.specify [create] [--no-issue] [--force]
```

- No action: Preview mode (shows what would be created without writing files)
- `create`: Execute mode (creates the spec file)
- `--no-issue`: Skip issue requirement for ad-hoc work
- `--force`: Overwrite existing spec without confirmation

## Description

This command creates lightweight specifications for the Lite workflow. It extracts content from the linked GitHub issue when available, or guides users through a 3-question conversation to gather spec content.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

First, verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display the following message and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `hasCreateAction`: true if `create` is present
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

### Step 4: Validate Issue Requirement

**If `hasNoIssueFlag` is false AND `issueNumber` is null**:

Display error and stop:
```
**Error**: No issue selected.

You must be on a feature branch (e.g., `042-feature-name`) or use the `--no-issue` flag.

To select an issue: `/mykit.backlog select`
To skip issue requirement: `/mykit.specify create --no-issue`
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

**If `hasCreateAction` is false (Preview Mode)**:

Display the spec content with a preview header:

```
## PREVIEW - Proposed Specification

{formatted spec content from Step 10}

---

**Note**: This is a preview. No files have been created.

To save this specification, run: `/mykit.specify create`
```

Stop execution here.

**If `hasCreateAction` is true (Execute Mode)**:

1. Create the spec directory if it doesn't exist
2. Write the spec content to `specPath`
3. Update `.mykit/state.json` with:
   - `current_feature.spec_path` = specPath
   - `workflow_step` = "specification"
   - `last_command` = "/mykit.specify"
   - `last_command_time` = current ISO timestamp

4. Display confirmation:

```
**Spec created successfully!**

**File**: {specPath}
**Source**: {contentSource === "issue" ? "Extracted from GitHub issue" : "Guided conversation"}

Next step: `/mykit.plan create` to create an implementation plan.
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| No issue selected | "No issue selected. Use `/mykit.backlog select` or `--no-issue` flag." |
| GitHub CLI unavailable | "Warning: Unable to fetch GitHub issue. Proceeding with guided conversation." |
| File write failed | "Error: Unable to create spec file at {path}. Check permissions." |

## Example Outputs

### Preview Mode

```
/mykit.specify

## PREVIEW - Proposed Specification

# Feature Specification: Add dark mode toggle

**Feature Branch**: `042-dark-mode`
**Created**: 2025-12-07
**Status**: Draft
**GitHub Issue**: [#42](https://github.com/owner/repo/issues/42)

## Overview

Add a toggle in settings to switch between light and dark themes.

...

---

**Note**: This is a preview. No files have been created.

To save this specification, run: `/mykit.specify create`
```

### Execute Mode

```
/mykit.specify create

**Spec created successfully!**

**File**: specs/042-dark-mode/spec.md
**Source**: Extracted from GitHub issue

Next step: `/mykit.plan create` to create an implementation plan.
```

### Guided Conversation Mode

```
/mykit.specify create

**Warning**: Issue body is minimal. Starting guided conversation.

**Spec: Summary**
What is this feature/change about?
> [User provides answer]

**Spec: Problem**
What problem does it solve?
> [User provides answer]

**Spec: Criteria**
What should be true when done?
> [User provides answer]

**Spec created successfully!**

**File**: specs/042-dark-mode/spec.md
**Source**: Guided conversation

Next step: `/mykit.plan create` to create an implementation plan.
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.start` | Sets session workflow type |
| `/mykit.backlog` | Select issue before running this command |
| `/mykit.plan` | Next step after spec creation |
| `/mykit.status` | Shows current workflow phase |
