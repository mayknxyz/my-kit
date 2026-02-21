# ADR Template Reference

Architecture Decision Records using the Nygard format. ADRs capture important architectural decisions along with their context and consequences.

## When to Write an ADR

Write an ADR when:

- **Choosing between technologies** — e.g., D1 vs Turso, Svelte vs React
- **Defining a pattern** — e.g., error handling strategy, state management approach
- **Making a trade-off** — e.g., performance vs simplicity, build-time vs runtime
- **Breaking a convention** — e.g., deviating from team standards for a specific reason
- **Decisions that are hard to reverse** — e.g., database schema, API contract, deployment platform

Don't write an ADR for obvious choices, trivial decisions, or temporary experiments.

## File Naming Convention

```
docs/adr/
├── 001-use-astro-for-frontend.md
├── 002-d1-for-database.md
├── 003-mermaid-for-diagrams.md
└── README.md  (index of all ADRs)
```

Format: `{NNN}-{kebab-case-title}.md` — sequential numbering, lowercase, hyphens.

## Nygard ADR Template

```markdown
# {NNN}. {Decision Title}

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded by [ADR-NNN](NNN-title.md)

## Context

What is the issue that we're seeing that is motivating this decision or change? Describe the forces at play — technical constraints, business requirements, team skills, timeline pressure.

Be factual and neutral. State the problem, not the solution.

## Decision

What is the change that we're proposing and/or doing? State the decision clearly and concisely.

Use active voice: "We will use X" not "X was chosen."

## Consequences

What becomes easier or more difficult to do because of this change? List both positive and negative consequences honestly.

### Positive

- Benefit one
- Benefit two

### Negative

- Trade-off one
- Trade-off two

## Alternatives Considered

### {Alternative A}

Brief description. Why it was rejected — specific technical or business reason.

### {Alternative B}

Brief description. Why it was rejected — specific technical or business reason.
```

## Status Lifecycle

```
Proposed → Accepted → [Deprecated | Superseded]
```

| Status | Meaning |
|--------|---------|
| Proposed | Under discussion, not yet decided |
| Accepted | Decision is in effect |
| Deprecated | Decision is no longer relevant |
| Superseded | Replaced by a newer ADR (link to it) |

## Worked Example

```markdown
# 003. Use Mermaid for All Diagrams

**Date**: 2025-06-15
**Status**: Accepted

## Context

The team needs a standard way to create technical diagrams (architecture, flows, ER). Diagrams should live in version control alongside code, render in GitHub and our doc site, and not require external tools.

## Decision

We will use Mermaid as the sole diagram tool. All architecture, flow, ER, and sequence diagrams will be written in Mermaid syntax within markdown files.

## Consequences

### Positive

- Diagrams are version-controlled and diffable
- Renders natively in GitHub markdown, Astro, and most doc tools
- No external tool licenses or accounts needed
- Single syntax to learn across all diagram types

### Negative

- Less visual control than GUI tools (Figma, draw.io)
- Complex diagrams can be hard to layout
- C4 support is limited to context diagrams

## Alternatives Considered

### PlantUML

Mature and feature-rich but requires a Java server for rendering. Doesn't render natively in GitHub.

### D2

Modern and well-designed but smaller ecosystem and no native GitHub rendering. Would require a build step.

### Draw.io / Excalidraw

GUI tools produce better visuals but output binary/JSON files that are not diffable. Creates a dependency on external tools.
```

## Writing Tips

- **Context section is the most important** — future readers need to understand *why*, not just *what*
- **Be honest about negatives** — ADRs that only list positives aren't trustworthy
- **Keep it short** — one page is ideal, two pages maximum
- **Link to related ADRs** — decisions build on each other
- **Don't update accepted ADRs** — write a new one that supersedes
