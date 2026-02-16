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

## Skill Evaluation Checklist

When reviewing a skill, check each criterion:

- **Code examples work** — do snippets reflect current API/syntax for the library version?
- **Anti-patterns are accurate** — are MUST NOT items genuinely harmful, not just preferences?
- **Versions are current** — does the skill reference the correct major version (e.g., Tailwind v4, Astro 5)?
- **Cross-references valid** — do referenced skills actually exist?
- **Word count in range** — SKILL.md is 200–400 words; longer content lives in `references/`
- **No duplication** — patterns aren't repeated across multiple skills
- **Triggers are specific** — frontmatter triggers match real use cases, not generic terms

## Common Improvement Patterns

What to look for when reviewing skills:

- **Missing real-world pattern** — you used a pattern not covered → add it
- **Outdated API** — a code example uses deprecated syntax → update it
- **Conflicting advice** — two skills give opposite guidance → reconcile
- **Override signal** — you ignored a rule during work → the rule may be wrong
- **Too abstract** — guidance says "follow best practices" without specifics → add concrete examples
- **Missing reference file** — SKILL.md exceeds 400 words or has complex topics → extract to `references/`

## Good vs Bad Skill Content

| Bad | Good | Why |
|-----|------|-----|
| "Use proper error handling" | "Use `{ ok: true; data: T } \| { ok: false; error: string }` Result type" | Concrete pattern |
| "Follow accessibility guidelines" | "Add `aria-label` to icon-only buttons" | Specific, actionable |
| Long config file walkthrough | Code snippet + link to docs | Concise, not duplicating docs |
| "Don't use bad patterns" | "`@apply` excessively — prefer utility classes in markup" | Shows what and why |

## Structured Reviews

Use `/mykit.review.skills` for end-of-session structured reviews of all activated skills.

## MUST DO

- Follow the frontmatter + sections format for all skills
- Keep skills 200–400 words (concise, actionable)
- Cross-reference related skills in the intro line
- Verify accuracy against actual behavior before proposing changes
- Check code examples against current library versions
- Add a `## References` routing table when creating `references/` files

## MUST NOT

- Add content Claude already knows well (basic language syntax, common CLI flags)
- Create skills longer than 400 words — split into `references/` files instead
- Duplicate content across skills — cross-reference instead
- Remove MUST DO / MUST NOT sections — every skill needs guardrails
- Add vague guidance without concrete examples or patterns
