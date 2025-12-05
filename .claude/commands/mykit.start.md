# /mykit.start

Start a new workflow session by selecting your work type.

## Usage

```
/mykit.start
```

No arguments required. The command always prompts for selection.

## Description

This command initiates a workflow session by prompting you to select the appropriate work type for your task. The selection determines how downstream commands behave.

## Implementation

When this command is invoked, perform the following:

### Step 1: Display Workflow Options

Present the user with the following selection prompt using the `AskUserQuestion` tool:

**Question**: "What type of work are you starting?"

**Options**:

| # | Option | Description |
|---|--------|-------------|
| 1 | Full workflow (Spec Kit) | Complex features requiring specification, planning, and structured implementation |
| 2 | Lite workflow (My Kit) | Simple changes that need some structure but not full documentation |
| 3 | Quick fix | Rapid fixes or minor changes with no formal planning |

Use the `AskUserQuestion` tool with these parameters:
- header: "Workflow"
- question: "What type of work are you starting?"
- options:
  1. label: "Full workflow (Spec Kit)", description: "Complex features requiring specification, planning, and structured implementation"
  2. label: "Lite workflow (My Kit)", description: "Simple changes that need some structure but not full documentation"
  3. label: "Quick fix", description: "Rapid fixes or minor changes with no formal planning"

### Step 2: Handle User Selection

Accept the user's selection. Valid inputs include:
- **Number**: "1", "2", or "3"
- **Name**: "full", "lite", "quickfix" (case-insensitive)
- **Full name**: "Full workflow", "Spec Kit", "Lite workflow", "My Kit", "Quick fix"

### Step 3: Set Session State

Based on the selection, set the session state in memory:

| Selection | session.type Value |
|-----------|-------------------|
| Option 1 (Full workflow) | `full` |
| Option 2 (Lite workflow) | `lite` |
| Option 3 (Quick fix) | `quickfix` |

**Important**: This state is in-memory only (conversation context). It resets when the Claude Code session ends.

### Step 4: Confirm and Direct to Next Step

After a valid selection, display a confirmation message and direct the user to the next command:

**For Full workflow (session.type = "full")**:
```
Session type set to: Full workflow (Spec Kit)

Next step: Use /mykit.backlog to select or create an issue to work on.
```

**For Lite workflow (session.type = "lite")**:
```
Session type set to: Lite workflow (My Kit)

Next step: Use /mykit.backlog to select or create an issue to work on.
```

**For Quick fix (session.type = "quickfix")**:
```
Session type set to: Quick fix

Next step: Use /mykit.backlog to select or create an issue to work on.
```

### Step 5: Handle Invalid Input

If the user provides invalid input (not a valid number or recognized name):
- Do not accept the input
- Re-prompt with the same options using `AskUserQuestion`
- Provide helpful guidance: "Please select 1, 2, or 3, or type the workflow name (full, lite, quickfix)"

## Session Behavior

- **Always prompts**: Each invocation presents the selection prompt (no remembered defaults)
- **In-memory state**: Session type persists only within the current Claude Code conversation
- **Resets on new session**: Starting a new Claude Code session requires re-selection

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.backlog` | Next step after workflow selection |
| `/mykit.status` | Shows current session type |
| `/mykit.reset` | Clears session state |
