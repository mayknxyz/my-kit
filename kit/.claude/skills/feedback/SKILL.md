---
name: feedback
description: >
  Skill maintenance advisor — skill quality, skill maintenance, skill review, SKILL.md editing,
  skill improvements. Use when evaluating, editing, or improving skills in ~/.claude/skills/.
  Triggers: skill quality, skill maintenance, skill review, SKILL.md editing, skill improvements.
---

# Skill Feedback

Skill maintenance advisor. Evaluates and improves skills in `~/.claude/skills/`. See `git` skill for commit conventions when committing skill changes.

## Skill Format Conventions

Every `SKILL.md` follows this structure:

1. **YAML frontmatter** — `name` (kebab-case) and `description` (with triggers)
2. **H1 title** — short role name
3. **Intro line** — senior role + cross-references to related skills
4. **Content sections** — key patterns, configuration, examples
5. **MUST DO** — mandatory practices (bullet list)
6. **MUST NOT** — anti-patterns to avoid (bullet list)
7. Optional: `references/` subdirectory for detailed docs loaded on demand

## Evaluating Skill Accuracy

When a skill activates during normal work, compare its guidance against actual behavior observed:

- Does the code pattern still work with current library versions?
- Did you override or ignore any rule? That rule may be wrong or unclear
- Did you use a pattern not covered? That's a gap worth adding
- Do two skills give conflicting advice? Flag the contradiction

## Structured Reviews

Use `/mykit.skill.review` for end-of-session structured reviews of all activated skills.

## MUST DO

- Follow the frontmatter + sections format for all skills
- Keep skills 200–400 words (concise, actionable)
- Cross-reference related skills in the intro line
- Verify accuracy against actual behavior before proposing changes

## MUST NOT

- Add content Claude already knows well (basic language syntax, common CLI flags)
- Create skills longer than 400 words — split into `references/` files instead
- Duplicate content across skills — cross-reference instead
- Remove MUST DO / MUST NOT sections — every skill needs guardrails
