# Implementation Plan: Add `diagrams`, `docs`, and `sop` domain skills

**Branch**: `044-add-diagrams-docs-sop-skills` | **Created**: 2026-02-18 | **Spec**: [spec.md](./spec.md)

## Technical Context

- **Technologies**: Markdown (SKILL.md files), Mermaid (diagram syntax examples), GNU Stow (deployment)
- **Dependencies**: None — pure content files
- **Integration Points**: CLAUDE.md skill registry, `stow -t ~ kit` deployment, cross-references to existing `git`, `copywriting`, `seo` skills

## Design Decisions

### Three Separate Skills (Not Merged)

**Choice**: Create `diagrams`, `docs`, and `sop` as independent skills
**Rationale**: Clean trigger keyword separation — someone asking "create a flowchart" vs "write a README" vs "write a deployment runbook" are in different mental modes. Each stays under the 400-word SKILL.md limit without forcing shared references.

### Mermaid-Only for Diagrams

**Choice**: Focus exclusively on Mermaid, not D2 or PlantUML
**Rationale**: Mermaid renders natively in GitHub markdown, Astro, and most doc sites. One tool to master, maximum portability.

### Dual SOP Coverage

**Choice**: Cover both deployment/ops runbooks and business/team processes
**Rationale**: The 5-component SOP structure (purpose, scope, prerequisites, steps, verification) applies equally to technical and business processes. Templates in references/ differentiate the two.

## Skills

- **feedback** — Skill creation conventions (200-400 words, MUST DO/NOT, references routing table)
- **git** — Commit conventions for the CLAUDE.md update

## Implementation Phases

### Phase 1: Create `diagrams` skill

Create the Mermaid-focused diagram skill with flowchart as the core inline pattern.

**Key Tasks**:
- Create `kit/.claude/skills/diagrams/SKILL.md` — frontmatter, diagram type selection table, flowchart worked example (shape cheat sheet, directions, edges, subgraphs), MUST DO/NOT
- Create `kit/.claude/skills/diagrams/references/types.md` — worked examples for sequence, ER, state, Gantt, C4 with syntax traps per type

### Phase 2: Create `docs` skill

Create the technical documentation skill with Diataxis framework and API docs inline.

**Key Tasks**:
- Create `kit/.claude/skills/docs/SKILL.md` — frontmatter, Diataxis type table, universal structure rules, API docs (TSDoc) pattern, changelog format, MUST DO/NOT
- Create `kit/.claude/skills/docs/references/readme.md` — full README template (mandatory + optional sections), anti-pattern table
- Create `kit/.claude/skills/docs/references/adr.md` — Nygard ADR template, naming convention, "when to write" guidance

### Phase 3: Create `sop` skill

Create the standard operating procedures skill covering ops and business processes.

**Key Tasks**:
- Create `kit/.claude/skills/sop/SKILL.md` — frontmatter, format selection table, 5 SOP components, step writing rules (Bad/Good/Why table), MUST DO/NOT
- Create `kit/.claude/skills/sop/references/templates.md` — numbered checklist, incident runbook, escalation matrix boilerplates

### Phase 4: Update CLAUDE.md and deploy

Update project documentation and verify deployment.

**Key Tasks**:
- Edit `CLAUDE.md` — update "24 Domain Skills" → "27 Domain Skills", add diagrams/docs/sop to skill list and references subdirectory line
- Deploy via `stow -t ~ kit` and verify symlinks

## Success Criteria Reference

- **SC-001**: Three new skill directories exist with SKILL.md files (200-400 words each)
- **SC-002**: Each skill has references/ subdirectory with specified files
- **SC-003**: CLAUDE.md reflects 27 domain skills
- **SC-004**: All skills deploy via `stow -t ~ kit`
- **SC-005**: No trigger keyword collisions with existing skills
