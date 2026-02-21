# Tasks: Add `diagrams`, `docs`, and `sop` domain skills

**Branch**: `044-add-diagrams-docs-sop-skills` | **Created**: 2026-02-18 | **Status**: Complete

## Skills

- **feedback** — Skill creation conventions (200-400 words, MUST DO/NOT, references routing table)
- **git** — Commit conventions for the CLAUDE.md update

## Implementation

- [x] T001 Create `kit/.claude/skills/diagrams/SKILL.md` — frontmatter with triggers, diagram type selection table, flowchart worked example (shape cheat sheet, directions, edges, subgraphs), references table, MUST DO/NOT (6 each)
- [x] T002 Create `kit/.claude/skills/diagrams/references/types.md` — worked examples and syntax traps for sequence diagrams, ER diagrams, state machines, Gantt charts, C4 architecture
- [x] T003 Create `kit/.claude/skills/docs/SKILL.md` — frontmatter with triggers, Diataxis doc type table, universal structure rules, API docs (TSDoc) pattern, changelog format (Keep a Changelog), references table, MUST DO/NOT (6 each)
- [x] T004 Create `kit/.claude/skills/docs/references/readme.md` — full README template (title, badges, overview, prerequisites, installation, usage, configuration, contributing, license), anti-pattern table
- [x] T005 Create `kit/.claude/skills/docs/references/adr.md` — Nygard ADR template (status, context, decision, consequences, alternatives), file naming convention, "when to write an ADR" guidance
- [x] T006 Create `kit/.claude/skills/sop/SKILL.md` — frontmatter with triggers, format selection table, 5 SOP components (purpose, scope, prerequisites, steps, verification), step writing rules with Bad/Good/Why table, references table, MUST DO/NOT (6 each)
- [x] T007 Create `kit/.claude/skills/sop/references/templates.md` — three boilerplate templates: numbered checklist (ops + business), incident runbook (severity, branching, rollback), escalation matrix (contact table + card template)
- [x] T008 Update `CLAUDE.md` — change "24 Domain Skills" to "27 Domain Skills", add diagrams/docs/sop to domain skill list and "Skills with references/ subdirectories" line
- [x] T009 Deploy via `stow -t ~ kit` and verify symlinks resolve for all three new skill directories
