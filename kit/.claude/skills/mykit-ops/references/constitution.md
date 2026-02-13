---
description: Create or update the project constitution from interactive or provided principle inputs, ensuring all dependent templates stay in sync.
handoffs:
  - label: Build Specification
    agent: mykit.specify
    prompt: Implement the feature specification based on the updated constitution. I want to build...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Usage

```
/mykit.constitution [-c|-r|-u|-d] [--force]
```

- No flags: Interactive CRUD menu
- `-c` / `--create`: Create constitution interactively from scratch or resolve all placeholders
- `-r` / `--read`: Display current constitution state and detect placeholders
- `-u` / `--update`: Amend existing constitution (partial or full updates)
- `-d` / `--delete`: Remove the constitution file
- `--force`: Skip confirmation prompts

This command is **mode-independent** — it works in Major, Minor, and Patch sessions.

## CRUD Routing

Parse the user input for CRUD flags (`-c`/`--create`, `-r`/`--read`, `-u`/`--update`, `-d`/`--delete`).

**If a CRUD flag is found**: Route directly to the corresponding operation below.

**If no CRUD flag is found**: Present the interactive menu:

Use `AskUserQuestion`:
- header: "Constitution"
- question: "What would you like to do?"
- options:
  1. label: "Create", description: "Create constitution from scratch or resolve placeholders"
  2. label: "View", description: "Display current constitution and placeholder status"
  3. label: "Amend", description: "Update existing constitution principles"
  4. label: "Delete", description: "Remove the constitution file"

Route based on selection:
- "Create" → treat as `-c` (maps to `create` action below)
- "View" → treat as `-r` (maps to preview/read mode below)
- "Amend" → treat as `-u` (maps to `amend` action below)
- "Delete" → treat as `-d` (maps to delete below)

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Parse Arguments

Parse the user input to determine:
- `action`: One of `create`, `amend`, or `null` (no action = preview mode)
- `hasForceFlag`: true if `--force` is present
- `userText`: Any remaining text after action/flags (used as amendment input)

**If an invalid action is provided** (not `create` or `amend`), and the text is not conversational amendment input, display:

```
**Error**: Invalid action.

Valid actions: create, amend
Or run without an action to preview the current constitution state.
```

**If user provides text without an explicit action** (e.g., `/mykit.constitution change principle 3 to ...`), treat as `amend` with the text as amendment input.

### Step 2: Load Constitution

Read the existing constitution file at `.mykit/memory/constitution.md`.

**If file does NOT exist**:
- If `action` is `create`: Proceed to Step 4 (create from scratch)
- Otherwise: Display error and stop:
  ```
  **Error**: No constitution file found at `.mykit/memory/constitution.md`.

  Run `/mykit.constitution -c` to create one.
  ```

### Step 3: Detect Placeholders

Scan the loaded constitution for placeholder tokens matching the pattern `[ALL_CAPS_IDENTIFIER]` (square brackets around uppercase letters, digits, and underscores).

Build a list of:
- `placeholders`: All unique placeholder tokens found (e.g., `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`)
- `placeholderCount`: Total number of unique placeholders

### Step 4: Extract Current Version Info

Parse the constitution footer line matching pattern:
```
**Version**: X.Y.Z | **Ratified**: YYYY-MM-DD | **Last Amended**: YYYY-MM-DD
```

Extract:
- `currentVersion`: The semantic version string (e.g., `1.0.0`)
- `ratificationDate`: The ratified date
- `lastAmendedDate`: The last amended date

If no version line found, set `currentVersion = "0.0.0"` (new constitution).

### Step 5: Route Based on Action

- **If `action` is null (no action)**: Go to Preview Mode (Step 6)
- **If `action` is "create"**: Go to Create Mode (Step 7)
- **If `action` is "amend"**: Go to Amend Mode (Step 10)

---

## Preview Mode (No Action)

### Step 6: Display Current State

Display the constitution overview:

```
## Constitution Preview

**File**: `.mykit/memory/constitution.md`
**Version**: {currentVersion}
**Ratified**: {ratificationDate}
**Last Amended**: {lastAmendedDate}

### Principles

{list each principle heading with its Roman numeral, e.g.:}
- I. Spec-First Development
- II. Issue-Linked Traceability
- III. Explicit Execution
- IV. Validation Gates
- V. Simplicity

### Placeholder Status

{if placeholderCount > 0:}
**⚠ {placeholderCount} unresolved placeholder(s) detected:**

{list each placeholder token}

Run `/mykit.constitution -c` to resolve placeholders interactively.

{if placeholderCount == 0:}
All placeholders resolved. Constitution is complete.

---

**Commands**:
- `/mykit.constitution -c` — Create or resolve all placeholders interactively
- `/mykit.constitution amend` — Amend existing principles
- `/mykit.constitution amend "change principle 3 to ..."` — Apply specific amendment
```

**Stop execution here for Preview Mode.**

---

## Create Mode

### Step 7: Interactive Constitution Creation

This mode guides the user through creating or completing a constitution.

**If constitution already exists AND `hasForceFlag` is false AND `placeholderCount` == 0**:

Use `AskUserQuestion` tool:
- header: "Existing Constitution"
- question: "A complete constitution already exists (v{currentVersion}). What would you like to do?"
- options:
  1. label: "Overwrite", description: "Start fresh and create a new constitution from scratch"
  2. label: "Cancel", description: "Keep the existing constitution"
- If user selects "Cancel": Display "Operation cancelled." and stop.

**If `hasForceFlag` is true**: Skip confirmation, proceed to overwrite.

### Step 8: Collect Constitution Values

Guide the user through defining the constitution interactively.

**Step 8a: Project Identity**

Use `AskUserQuestion` to ask:
- header: "Project Name"
- question: "What is the project name for this constitution?"
- options:
  1. label: "{inferred from repo name or README}", description: "Use detected project name"
  2. label: "Custom", description: "Enter a custom project name"

Store answer as `projectName`.

**Step 8b: Principle Count**

Use `AskUserQuestion` to ask:
- header: "Principles"
- question: "How many core principles should the constitution define?"
- options:
  1. label: "5 (Recommended)", description: "Standard set — enough for governance without bloat"
  2. label: "3", description: "Minimal — only the most critical principles"
  3. label: "7", description: "Extended — comprehensive governance coverage"
  4. label: "Custom", description: "Specify a different number"

Store answer as `principleCount`.

**Step 8c: For each principle (1 to principleCount)**

Use `AskUserQuestion` to ask:
- header: "Principle {N}"
- question: "What is principle {N}? Provide a short name and brief description."
- options: (present suggested principles based on repo context if available, plus "Custom")

Store each as `principle_{N}_name` and `principle_{N}_description`.

If the user defers a principle (says "skip" or "later"), mark it with a `TODO(PRINCIPLE_{N}): User deferred` placeholder.

**Step 8d: Governance Settings**

Use `AskUserQuestion` to ask:
- header: "Governance"
- question: "What is the ratification date for this constitution?"
- options:
  1. label: "Today ({current date})", description: "Set ratification to today"
  2. label: "Keep existing", description: "Preserve the current ratification date (if exists)"
  3. label: "Custom", description: "Enter a specific date"

### Step 9: Generate and Write Constitution

1. Build the constitution content:
   - Use the structure from the existing constitution as a template
   - Replace all placeholder tokens with collected values
   - Set `CONSTITUTION_VERSION` to `1.0.0` if new, or increment appropriately
   - Set dates in ISO format (YYYY-MM-DD)
   - Dynamically generate principle sections (I, II, III, ...) matching `principleCount`
   - Each principle section includes: name heading, rules (as bullet list), rationale
   - Include Command Conventions and Governance sections

2. Run validation (Step 15)
3. Generate Sync Impact Report (Step 16)
4. Write the constitution to `.mykit/memory/constitution.md`
5. Output final summary (Step 17)

**Continue to Step 15 (Validation).**

---

## Amend Mode

### Step 10: Determine Amendment Scope

Analyze what the user wants to change:

**If `userText` is provided** (partial update from conversation input):
- Parse the user's amendment request
- Identify which section(s) are targeted (principle name, governance, etc.)
- Store the old content of targeted sections for diff comparison
- Go to Step 12

**If `userText` is empty** (interactive amendment):
- Go to Step 11

### Step 11: Interactive Amendment

Use `AskUserQuestion` to ask:
- header: "Amendment"
- question: "What would you like to amend?"
- options:
  1. label: "Add principle", description: "Add a new principle to the constitution"
  2. label: "Edit principle", description: "Modify an existing principle's name, rules, or rationale"
  3. label: "Remove principle", description: "Remove an existing principle"
  4. label: "Edit governance", description: "Modify the governance section"

**Based on selection**:

**Add principle**:
- Ask for principle name and description via `AskUserQuestion`
- Determine insertion position (after last existing principle)
- This is a MINOR version bump

**Edit principle**:
- List existing principles and ask which to edit via `AskUserQuestion`
- Ask for updated content
- If name changed: This is a MINOR bump; if only wording: PATCH bump; if fundamentally redefined: MAJOR bump

**Remove principle**:
- List existing principles and ask which to remove via `AskUserQuestion`
- Confirm removal (unless `--force`)
- This is a MAJOR version bump

**Edit governance**:
- Display current governance section
- Ask for changes
- This is a PATCH bump (unless changing amendment procedure fundamentally, then MINOR)

### Step 12: Apply Amendment

1. Load the current constitution content
2. Store the old content for comparison
3. Apply the targeted changes:
   - For partial updates: Modify ONLY the specified sections, preserve everything else unchanged
   - For principle additions: Insert new principle section with correct Roman numeral
   - For principle removals: Remove the section and renumber remaining principles
   - For edits: Replace the targeted content in place
4. Verify all other sections remain unchanged (diff check)

### Step 13: Classify Version Bump

Compare old constitution content with new to classify the change:

- **MAJOR** (X.0.0): Principle removed or fundamentally redefined (meaning changed, not just wording)
- **MINOR** (x.Y.0): New principle added or existing principle materially expanded
- **PATCH** (x.y.Z): Wording clarifications, typo fixes, non-semantic refinements

Present the proposed bump to the user:

```
**Proposed Version Bump**: {currentVersion} → {newVersion} ({MAJOR|MINOR|PATCH})
**Rationale**: {explanation of why this bump level was chosen}
```

Use `AskUserQuestion` to confirm:
- header: "Version Bump"
- question: "Accept the proposed version bump?"
- options:
  1. label: "Accept", description: "Use {newVersion}"
  2. label: "Override", description: "Specify a different version"

If user overrides, accept their version.

### Step 14: Update Dates and Version

- Set `LAST_AMENDED_DATE` to today's date (ISO format YYYY-MM-DD)
- Set `CONSTITUTION_VERSION` to the confirmed new version
- Preserve `RATIFICATION_DATE` unchanged

---

## Validation, Sync, and Output (Shared Steps)

### Step 15: Post-Generation Validation

Validate the updated constitution content:

1. **Placeholder check**: Scan for any remaining `[ALL_CAPS_IDENTIFIER]` tokens
   - If found and not intentionally deferred (no TODO marker): Display error listing unresolved tokens
   - If found with TODO marker: Note in Sync Impact Report as deferred items

2. **Version line check**: Verify the footer version line matches the determined version

3. **Date format check**: Verify all dates are in ISO format (YYYY-MM-DD)

4. **Content quality check**: Scan principle sections for vague language ("should" without context, "robust", "intuitive" without quantification)
   - Flag any vague terms found (informational, not blocking)

### Step 16: Dependency Scan and Sync Impact Report

Scan dependent files for constitution references (check + report only, do NOT auto-edit):

1. **Templates scan**:
   - Read `$HOME/.claude/skills/mykit/references/templates/minor/plan.md` — check Constitution Check section alignment
   - Read `$HOME/.claude/skills/mykit/references/templates/minor/spec.md` — check for principle references
   - Read `$HOME/.claude/skills/mykit/references/templates/minor/tasks.md` — check for principle-driven task types

2. **Command files scan**:
   - Read each `.claude/commands/mykit.*.md` file
   - Check for references to constitution principles by name
   - Flag any that reference principles that were renamed, removed, or added

3. **Documentation scan**:
   - Read `README.md` — check for outdated principle references
   - Read files in `docs/` — check for stale constitution mentions

4. **Generate Sync Impact Report** as HTML comment and prepend to constitution file:

```html
<!--
Sync Impact Report
==================
Version change: {oldVersion} -> {newVersion}
Modified principles: {list of old title -> new title if renamed}
Added sections: {list}
Removed sections: {list}
Templates requiring updates:
  - $HOME/.claude/skills/mykit/references/templates/minor/plan.md: {✅ aligned | ⚠ needs review}
  - $HOME/.claude/skills/mykit/references/templates/minor/spec.md: {✅ aligned | ⚠ needs review}
  - $HOME/.claude/skills/mykit/references/templates/minor/tasks.md: {✅ aligned | ⚠ needs review}
Command files: {✅ aligned | ⚠ {count} file(s) reference changed principles}
Documentation: {✅ aligned | ⚠ {count} file(s) need updates}
Follow-up TODOs: {list of deferred items, or "None"}
-->
```

5. Write the updated constitution (with Sync Impact Report prepended) to `.mykit/memory/constitution.md`

### Step 17: Output Final Summary

Display completion summary:

```
**Constitution updated successfully!**

**File**: `.mykit/memory/constitution.md`
**Version**: {oldVersion} → {newVersion} ({MAJOR|MINOR|PATCH})
**Bump Rationale**: {explanation}
**Principles**: {principleCount} defined
**Last Amended**: {today's date}

### Sync Impact Summary

| File | Status |
|------|--------|
| plan-template.md | {✅ Aligned / ⚠ Needs review} |
| spec-template.md | {✅ Aligned / ⚠ Needs review} |
| tasks-template.md | {✅ Aligned / ⚠ Needs review} |
| Command files | {✅ Aligned / ⚠ N file(s) to review} |
| Documentation | {✅ Aligned / ⚠ N file(s) to review} |

{if any files need review:}
### Files Flagged for Manual Follow-Up

{list of files with descriptions of what needs attention}

### Suggested Commit Message

```
docs: amend constitution to v{newVersion} ({brief change description})
```
```

---

## Formatting & Style Requirements

- Use Markdown headings exactly as in the existing constitution structure (do not demote/promote levels)
- Wrap long rationale lines for readability (<100 chars ideally)
- Keep a single blank line between sections
- Avoid trailing whitespace
- Dates MUST be ISO format YYYY-MM-DD
- Principles MUST be declarative and testable (use MUST/SHOULD instead of vague "should")
- Do not create a new template; always operate on the existing `.mykit/memory/constitution.md` file

## Error Handling

| Error | Message |
|-------|---------|
| No constitution file (non-create) | "No constitution file found. Run `/mykit.constitution -c` to create one." |
| Invalid action | "Invalid action. Valid actions: create, amend" |
| Unresolved placeholders after create | "Validation failed: {count} unresolved placeholder(s) remain." |
| File write failed | "Error: Unable to write constitution. Check permissions." |
