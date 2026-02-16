# /mykit.review.skills [skill-names...]

Review skills activated this session and propose actionable improvements.

## Usage

```
/mykit.review.skills              # review all activated skills
/mykit.review.skills tailwind svelte  # review specific skills only
```

## User Input

```text
$ARGUMENTS
```

## Description

End-of-session review. Identifies skills and commands that fired during the session, evaluates
their accuracy/completeness, and outputs a numbered improvement list.

## Implementation

### Step 1: Identify Activated Skills and Commands

Look back through the conversation for system reminders listing activated skills.
If `$ARGUMENTS` specifies skill names, filter to only those.

Also identify any **command files** (`~/.claude/commands/mykit.*.md`) that were invoked during the session. These contain implementation logic that may also need improvements.

### Step 2: Load Evaluation Criteria

Read `~/.claude/skills/feedback/SKILL.md` to load the Skill Evaluation Checklist and Common Improvement Patterns. Use these as the baseline for consistent, thorough evaluation in Step 3.

### Step 3: Read Each Skill

For each activated skill, read `~/.claude/skills/{name}/SKILL.md`

For each invoked command, read `~/my-kit-v2/kit/.claude/commands/{name}.md`

### Step 4: Evaluate Each Skill

For each skill/command, assess:

1. **Helpfulness** - Was it helpful or did you ignore/override parts?
2. **Clarity** - Any rules that were unclear or contradictory?
3. **Gaps** - Patterns used in this session that should be added?
4. **Accuracy** - Anything outdated or wrong based on what you saw?
5. **Conflicts** - Does it contradict another skill?

Cross-check against the `feedback` skill's evaluation checklist (code examples work, anti-patterns accurate, versions current, cross-references valid, word count in range, no duplication, triggers specific).

### Step 5: Output Review

Display numbered, actionable list grouped by skill:

---

## Skill Review

### tailwind (activated)
1. Helpful: @theme directive guidance prevented v3 patterns
2. Gap: Missing `@variant` directive documentation
3. Outdated: `color-mix()` syntax changed in v4.1

### svelte (activated)
4. Helpful: Runes migration table caught $: usage
5. Gap: No guidance on $state.snapshot() for deep copies

### Summary
- {n} skills reviewed, {n} commands reviewed
- {n} improvements proposed
- Priority: {highest-impact change}

---

### Step 6: Offer to Apply

Always offer to apply improvements directly. Skills live at `~/.claude/skills/` (symlinked from `~/my-kit-v2/kit/.claude/skills/`) and commands live at `~/my-kit-v2/kit/.claude/commands/` - both are writable from any working directory.

When the user says "apply all" or references specific numbers, edit the files directly.
