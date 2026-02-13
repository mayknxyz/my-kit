# /mykit.start

Start a new workflow session — from version checks to ready-to-code in a single command.

## Usage

```
/mykit.start
```

No arguments required. The command guides you through issue selection, mode selection, and branch creation.

## Description

This command is the single entry point for all work. It performs version checks, shows open GitHub issues, lets you pick/create/discuss an issue, auto-suggests a workflow mode, and creates or checks out a feature branch.

## Implementation

When this command is invoked, perform the following:

### Step 0: Version Checks

Before starting, perform two version checks. **Both checks are best-effort** — if `gh` is unavailable or the network is down, silently skip both checks and proceed to Step 1.

**Check 1: My Kit version**

1. Read `$HOME/.claude/skills/mykit/references/VERSION` to get the installed version (e.g., `v2.0.0`)
2. Run: `gh release list --repo mayknxyz/my-kit-v2 --limit 1 --exclude-drafts --exclude-pre-releases --json tagName --jq '.[0].tagName'`
3. Compare installed version against latest
4. **If outdated**: Auto-run `/mykit.upgrade run` to update, then continue
5. **If current or check fails**: Silently continue

**Check 2: Spec-kit version**

1. Read `$HOME/.claude/skills/mykit/references/SPEC_KIT_VERSION` to get the baked-in spec-kit version (e.g., `v0.0.93`)
2. Run: `gh release list --repo github/spec-kit --limit 1 --exclude-drafts --exclude-pre-releases --json tagName --jq '.[0].tagName'`
3. Compare installed version against latest
4. **If outdated**: Display warning (do NOT auto-upgrade):
   ```
   spec-kit {latest} available (my-kit has {installed} baked in).
   Review: https://github.com/github/spec-kit/releases
   To sync: open ~/my-kit-v2 and run /mykit.sync
   ```
5. **If current or check fails**: Silently continue

**Caching**: To avoid hitting GitHub on every session, cache results in `.mykit/.version-check-cache` with a 24-hour TTL. The `check_for_updates()` function in `$HOME/.claude/skills/mykit/references/scripts/version.sh` handles this logic.

### Step 1: Check GH Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display error and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

Verify `gh` CLI is available:

```bash
command -v gh
```

**If `gh` is not installed**, display and stop:

```
**Error**: GitHub CLI (`gh`) is not installed.

Install it:
  - macOS: `brew install gh`
  - Ubuntu/Debian: `sudo apt install gh`
  - Arch: `pacman -S github-cli`

Then authenticate: `gh auth login`
```

Verify `gh` is authenticated:

```bash
gh auth status 2>/dev/null
```

**If not authenticated**, display and stop:

```
**Error**: GitHub CLI is not authenticated.

Run `gh auth login` to authenticate.
```

### Step 2: Fetch and Display Open Issues

Fetch open issues from GitHub:

```bash
gh issue list --state open --json number,title,labels --limit 50
```

**If the command fails**, display:

```
**Error**: Failed to fetch issues from GitHub.

Ensure you have access to this repository and `gh` is properly authenticated.
Run `gh auth status` to check your authentication.
```

**If issues are returned**, sort them for display:
- Priority labels first: `priority: high` → `priority: medium` → `priority: low` → unlabeled
- Within same priority, sort by issue number (ascending)

Display the issues as a compact list — one line per issue:

```
## Open Issues

- #14 - Enhance search | enhancement, priority: high
- #15 - Fix login bug | bug, priority: medium
- #20 - Refactor auth module
...

**{N} open issues**
```

Format rules:
- Each line: `- #{number} - {title}` followed by ` | {comma-separated labels}` only if labels exist
- No assignees column, no custom row numbers, no table format
- Omit the label suffix entirely for issues with no labels

**If no issues are returned**, display:

```
**No open issues found.**

You can create a new issue or discuss what you'd like to work on.
```

Then skip directly to the three-way prompt (Step 3) — the "Pick existing issue" option will be hidden since there are no issues.

### Step 3: Three-Way Interactive Prompt

Use `AskUserQuestion` to present the main choices:

**If issues exist**:

- header: "What to work on"
- question: "How would you like to proceed?"
- options:
  1. label: "Pick existing issue", description: "Select from the open issues listed above"
  2. label: "Create new issue", description: "Create a new GitHub issue with auto-assign and labels"
  3. label: "Discuss first", description: "Talk through what you want to work on before deciding"

**If no issues exist**:

- header: "What to work on"
- question: "How would you like to proceed?"
- options:
  1. label: "Create new issue", description: "Create a new GitHub issue with auto-assign and labels"
  2. label: "Discuss first", description: "Talk through what you want to work on before deciding"

Route based on selection:
- "Pick existing issue" → Go to Step 4
- "Create new issue" → Go to Step 5
- "Discuss first" → Go to Step 6

### Step 4: Pick Existing Issue

Present issues in batches of 4 using `AskUserQuestion`:

- header: "Select Issue"
- question: "Which issue would you like to work on?"
- options (up to 4 from current batch):
  1. label: "#{number} {title}" (truncated to fit), description: "Labels: {labels}" (or "No labels" if none)
  2. ... (repeat for each issue in batch)
  - If more issues remain beyond the current batch of 4, add a final option:
    - label: "More...", description: "Show next batch of issues"

**If user selects "More..."**: Show the next batch of 4 issues. Repeat until user selects an issue or all issues have been shown.

**If user selects an issue**: Store `selectedIssueNumber` and `selectedIssueTitle`. Fetch full issue details:

```bash
gh issue view {selectedIssueNumber} --json labels --jq '[.labels[].name]'
```

Store `selectedIssueLabels`. Go to Step 7.

### Step 5: Create New Issue (Inline)

#### 5a: Get Issue Title

Use a normal conversational message (NOT `AskUserQuestion`):
> "What should the issue title be?"

Wait for user response. Store as `newIssueTitle`.

#### 5b: Get Issue Description

Use a normal conversational message:
> "Briefly describe the issue (1-3 sentences):"

Wait for user response. Store as `newIssueDescription`.

#### 5c: Select Labels

Fetch available labels:

```bash
gh label list --json name,description --limit 30
```

Present labels using `AskUserQuestion`:

- header: "Labels"
- question: "Which labels should this issue have?"
- multiSelect: true
- options (up to 4 most common/relevant labels):
  1. label: "{labelName}", description: "{labelDescription}"
  2. ... (repeat for available labels)

Store selected labels as `newIssueLabels`.

#### 5d: Create the Issue

```bash
gh issue create --title "{newIssueTitle}" --body "{newIssueDescription}" --assignee @me --label "{label1}" --label "{label2}" ...
```

Parse the output to extract the new issue number.

Display:
```
**Issue created!**

**Issue**: #{newIssueNumber} - {newIssueTitle}
**Assigned to**: @me
**Labels**: {newIssueLabels}
```

Set `selectedIssueNumber = newIssueNumber`, `selectedIssueTitle = newIssueTitle`, `selectedIssueLabels = newIssueLabels`. Go to Step 7.

### Step 6: Discuss First

Start a conversational exchange to understand the user's work:

1. **Ask**: "What are you thinking about working on?" — Use a normal conversational message (NOT `AskUserQuestion`). Keep it friendly and brief.
2. **Listen**: The user describes their work.
3. **Explore** (if helpful): Read relevant files, fetch GitHub issue details if the user mentions an issue number, look at related code. Do this silently — don't narrate your exploration.
4. **Clarify** (if needed): Ask 1-2 follow-up questions to understand the scope.
5. **After discussion is sufficient**, use `AskUserQuestion` to prompt:
   - header: "Next step"
   - question: "Now that we've discussed, how would you like to proceed?"
   - options:
     1. label: "Create new issue", description: "Create a GitHub issue based on our discussion"
     2. label: "Pick existing issue", description: "Select from the open issues list"

Route based on selection:
- "Create new issue" → Go to Step 5 (pre-fill title/description from discussion context)
- "Pick existing issue" → Go to Step 4

### Step 7: Auto-Suggest Mode Based on Labels

Read `docs/MODE_RULES.md` for the complete decision criteria.

Determine the recommended mode from `selectedIssueLabels`:

| Label contains | Suggested Mode | Reasoning |
|----------------|---------------|-----------|
| `bug` | Patch | Bug fixes don't require formal spec workflow |
| `security` | Patch | Security patches are urgent fixes |
| `documentation` | Patch | Docs are content updates |
| `enhancement` | Minor | Enhancements add new capability |
| `feature` | Minor | Features add new capability |
| `breaking` | Major | Breaking changes need full spec workflow |

**If no label matches** or labels are ambiguous: Default to **Minor**.

**If the user said "just let me pick" at any point**: Skip the recommendation — present all 3 options equally.

Present the recommendation with brief reasoning:

> Based on the issue labels, this looks like a **{Mode}** change — {brief reasoning}.

Use `AskUserQuestion` to confirm, with the recommended option first:

- header: "Mode"
- question: "Which mode should we use?"
- Options (order the recommended one first):
  - label: "Major", description: "Breaking changes or new project — full spec-driven workflow with quality gates"
  - label: "Minor", description: "New backward-compatible capability — lightweight spec workflow"
  - label: "Patch", description: "Bug fixes, refactoring, performance, polish — all workflow steps optional"

### Step 8: Set Session State

Based on the selection, set the session state in memory:

| Selection | session.type Value |
|-----------|-------------------|
| Major | `"major"` |
| Minor | `"minor"` |
| Patch | `"patch"` |

**Important**: This state is in-memory only (conversation context). It resets when the Claude Code session ends.

### Step 9: Check for Existing Branch and Create/Checkout

Check if a branch already exists for the selected issue number. Search in three places:

**Local branches**:
```bash
git branch --list "[0]*{selectedIssueNumber}-*"
```

**Remote branches**:
```bash
git branch -r --list "origin/[0]*{selectedIssueNumber}-*"
```

**Specs directories**:
Check if a directory exists at `specs/` matching the pattern `{paddedNumber}-*`.

**If a matching branch is found**:

```bash
git checkout {existing_branch_name}
```

Update `.mykit/state.json`:
- `current_feature.spec_path` = `specs/{existing_branch_name}/spec.md`
- `workflow_step` = "start"
- `last_command` = "/mykit.start"
- `last_command_time` = current ISO timestamp

Display:
```
**Switched to existing branch!**

Session type set to: **{Major/Minor/Patch}**

**Branch**: {existing_branch_name}
**Issue**: #{selectedIssueNumber} - {selectedIssueTitle}

This issue already has a feature branch. Checked out the existing branch.

Next step: Check your progress with `/mykit.status`
```

Stop execution here.

**If no existing branch is found**:

1. Generate a slug from the issue title:
   - Lowercase, replace spaces/special chars with hyphens
   - Keep 2-4 meaningful words (filter stop words)

2. Run the branch creation script:
   ```bash
   $HOME/.claude/skills/mykit/references/scripts/create-new-feature.sh --json --number {selectedIssueNumber} --short-name "{slug}" "{selectedIssueTitle}"
   ```

3. Parse the JSON output to get `BRANCH_NAME`, `SPEC_FILE`, `FEATURE_NUM`.

4. Update `.mykit/state.json`:
   - `current_feature.spec_path` = `specs/{BRANCH_NAME}/spec.md`
   - `workflow_step` = "start"
   - `last_command` = "/mykit.start"
   - `last_command_time` = current ISO timestamp

5. Display confirmation:

```
**Ready to go!**

Session type set to: **{Major/Minor/Patch}**

**Branch**: {BRANCH_NAME}
**Issue**: #{selectedIssueNumber} - {selectedIssueTitle}
**Spec directory**: specs/{BRANCH_NAME}/

Next step:
{if session.type is "patch"}
`/mykit.specify -c` to create a spec, or `/mykit.implement` to start implementing directly.
{else}
`/mykit.specify -c` to create a feature specification.
{end if}
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| gh CLI not installed | "GitHub CLI (`gh`) is not installed. Install it and run `gh auth login`." |
| gh not authenticated | "GitHub CLI is not authenticated. Run `gh auth login`." |
| Issue fetch failed | "Failed to fetch issues from GitHub. Check authentication with `gh auth status`." |
| Issue creation failed | "Failed to create GitHub issue. Check permissions and try again." |
| Branch creation failed | "Failed to create feature branch. Check git status and try again." |

## Session Behavior

- **Single entry point**: Version check → issue selection → mode selection → branch creation in one command
- **In-memory state**: Session type persists only within the current Claude Code conversation
- **Resets on new session**: Starting a new Claude Code session requires re-running `/mykit.start`

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.specify` | Next step after starting a session (all modes) |
| `/mykit.implement` | Alternative next step — skip to implementation (Patch mode) |
| `/mykit.status` | Shows current session type and progress |
| `/mykit.reset` | Clears session state |
