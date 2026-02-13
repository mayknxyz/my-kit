# /mykit.skill.review [skill-names...]

Review skills activated this session and propose actionable improvements.

## Usage

```
/mykit.skill.review              # review all activated skills
/mykit.skill.review tailwind svelte  # review specific skills only
```

## User Input

```text
$ARGUMENTS
```

## Description

End-of-session review. Identifies skills that fired during the session, evaluates
their accuracy/completeness, and outputs a concise improvement list.

## Implementation

### Step 1: Identify Activated Skills

Look back through the conversation for system reminders listing activated skills.
If `$ARGUMENTS` specifies skill names, filter to only those.

### Step 2: Read Each Skill

For each activated skill, read `~/.claude/skills/{name}/SKILL.md`

### Step 3: Evaluate Each Skill

For each skill, assess:

1. **Helpfulness** — Was it helpful or did you ignore/override parts?
2. **Clarity** — Any rules that were unclear or contradictory?
3. **Gaps** — Patterns used in this session that should be added?
4. **Accuracy** — Anything outdated or wrong based on what you saw?
5. **Conflicts** — Does it contradict another skill?

### Step 4: Output Review

Display concise, actionable list grouped by skill:

---

## Skill Review

### tailwind (activated)
- ✓ Helpful: @theme directive guidance prevented v3 patterns
- △ Gap: Missing `@variant` directive documentation
- ✗ Outdated: `color-mix()` syntax changed in v4.1

### svelte (activated)
- ✓ Helpful: Runes migration table caught $: usage
- △ Gap: No guidance on $state.snapshot() for deep copies

### Summary
- {n} skills reviewed
- {n} improvements proposed
- Priority: {highest-impact change}

---

### Step 5: Offer to Apply (if in my-kit repo)

If current directory is `~/my-kit` or `~/my-claude`, offer to edit the SKILL.md
files directly. Otherwise, just output the review.
