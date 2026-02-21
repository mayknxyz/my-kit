---
name: docs
description: >
  Technical documentation — READMEs, ADRs, API docs, changelogs, Diataxis framework. Use when
  writing project documentation, README files, architecture decision records, or API references.
  Triggers: documentation, README, ADR, architecture decision record, changelog, API docs, TSDoc,
  JSDoc, Diataxis, technical writing, docs.
---

# Documentation

Senior technical writer. Diataxis framework for doc types. Structure before prose. See `diagrams` skill for visual aids, `sop` skill for operational procedures, `git` skill for changelog commit conventions.

## Diataxis Doc Type Selection

| Type | Purpose | Reader Needs | Format |
|------|---------|-------------|--------|
| Tutorial | Learning by doing | "Show me how" | Step-by-step walkthrough |
| How-to | Solving a problem | "Help me do X" | Goal-oriented steps |
| Explanation | Understanding concepts | "Help me understand" | Narrative prose |
| Reference | Looking up facts | "Give me the details" | Tables, signatures, specs |

Pick the type **before writing**. Mixing types creates unfocused docs.

## Universal Structure Rules

1. **Title** — what the doc covers (not what it is)
2. **Overview** — 1-2 sentences, the "why" before the "what"
3. **Body** — organized by reader tasks, not by code structure
4. **Examples** — concrete, copy-pasteable, tested
5. **See also** — cross-references to related docs

## API Documentation (TSDoc)

```ts
/**
 * Sends a transactional email via the configured provider.
 *
 * @param to - Recipient email address
 * @param subject - Email subject line (max 150 chars)
 * @param body - HTML email body
 * @returns Result with message ID on success
 *
 * @example
 * ```ts
 * const result = await sendEmail("user@example.com", "Welcome", "<p>Hello</p>");
 * if (result.ok) console.log(result.data.messageId);
 * ```
 */
```

Every public function needs: **one-line summary**, **`@param`** for each parameter, **`@returns`**, and **`@example`** with runnable code.

## Changelog Format (Keep a Changelog)

```markdown
## [1.2.0] - 2025-03-15

### Added
- Contact form with Turnstile bot protection

### Changed
- Upgrade Astro to 5.x

### Fixed
- JSON-LD schema missing on services page
```

Categories in order: Added, Changed, Deprecated, Removed, Fixed, Security.

## References

| Topic | File | Load When |
|-------|------|-----------|
| README template | [readme.md](references/readme.md) | Writing a new README or restructuring an existing one |
| ADR template | [adr.md](references/adr.md) | Recording an architecture decision |

## MUST DO

- Choose a Diataxis type before writing any doc
- Start every doc with a 1-2 sentence overview
- Include runnable code examples in API docs and how-tos
- Use tables for reference material — not prose
- Keep headings task-oriented ("Install dependencies" not "Installation section")
- Add `@example` with tested code to every public TSDoc comment

## MUST NOT

- Mix tutorial and reference in one doc — split them
- Write docs organized by file structure instead of reader tasks
- Skip the overview — readers need the "why" first
- Use placeholder examples (`foo`, `bar`) — use realistic values
- Duplicate content between docs — cross-reference instead
- Write changelogs as commit logs — group by user impact
