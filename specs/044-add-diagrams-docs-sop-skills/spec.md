# Feature Specification: Add `diagrams`, `docs`, and `sop` domain skills

**Feature Branch**: `044-add-diagrams-docs-sop-skills`
**Created**: 2026-02-18
**Status**: Draft
**GitHub Issue**: [#44](https://github.com/mayknxyz/my-kit/issues/44)

## Overview

The my-kit skill system has 24 domain skills covering web development topics but nothing for flowcharts/diagrams, technical documentation, or standard operating procedures. These are frequently needed when designing systems, writing project docs, and defining repeatable processes. Create 3 new domain skills (7 new files total), then update CLAUDE.md counts.

## Problem

The current skill set lacks coverage for non-code artifacts — diagrams, documentation, and operational procedures — forcing ad-hoc approaches without consistent patterns or guardrails.

## User Scenarios

### User Story 1 - Create Mermaid Diagrams (Priority: P1)

User needs to create a system architecture diagram, data flow, or process flowchart using text-based Mermaid syntax.

**Acceptance Scenarios**:

1. **Given** the user asks to create a flowchart, **When** the `diagrams` skill activates, **Then** it provides the correct Mermaid syntax, shape cheat sheet, and best practices
2. **Given** the user needs a sequence or ER diagram, **When** they load the references, **Then** `types.md` provides worked examples and syntax traps for each diagram type

### User Story 2 - Write Technical Documentation (Priority: P1)

User needs to write a README, API docs, ADR, or changelog following consistent structure and conventions.

**Acceptance Scenarios**:

1. **Given** the user asks to write documentation, **When** the `docs` skill activates, **Then** it provides the Diataxis framework for choosing doc type and universal structure rules
2. **Given** the user needs a README template, **When** they load `references/readme.md`, **Then** it provides a complete copy-paste template with mandatory and optional sections
3. **Given** the user needs an ADR, **When** they load `references/adr.md`, **Then** it provides the Nygard template with status, context, decision, and consequences

### User Story 3 - Write Standard Operating Procedures (Priority: P1)

User needs to create a runbook, checklist, or escalation path for operational or business processes.

**Acceptance Scenarios**:

1. **Given** the user asks to write an SOP, **When** the `sop` skill activates, **Then** it provides the 5 SOP components (purpose, scope, prerequisites, steps, verification) and step-writing rules
2. **Given** the user needs a template, **When** they load `references/templates.md`, **Then** it provides numbered checklist, incident runbook, and escalation matrix boilerplates

## Requirements

### Functional Requirements

- **FR-001**: Create `diagrams` skill with SKILL.md (Mermaid-only, flowchart core pattern, diagram type selection table) and `references/types.md` (sequence, ER, state, Gantt, C4 worked examples)
- **FR-002**: Create `docs` skill with SKILL.md (Diataxis framework, universal structure rules, API docs pattern, changelog format) and `references/readme.md` + `references/adr.md`
- **FR-003**: Create `sop` skill with SKILL.md (format selection table, 5 SOP components, step writing rules) and `references/templates.md` (3 boilerplate templates)
- **FR-004**: Update CLAUDE.md to reflect 27 domain skills and add all three to the references subdirectory list
- **FR-005**: Each SKILL.md follows existing conventions: YAML frontmatter with triggers, role intro with cross-references, content tables, MUST DO/MUST NOT (6 bullets each), 200-400 words
- **FR-006**: Cross-references: diagrams ↔ docs ↔ sop, plus docs → git (changelog conventions)

## Success Criteria

- **SC-001**: Three new skill directories exist with SKILL.md files following the 200-400 word convention
- **SC-002**: Each SKILL.md has references/ subdirectory with the specified files
- **SC-003**: CLAUDE.md updated to reflect 27 domain skills
- **SC-004**: All skills deploy correctly via `stow -t ~ kit`
- **SC-005**: No trigger keyword collisions with existing skills
