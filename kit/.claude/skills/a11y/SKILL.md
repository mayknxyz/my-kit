---
name: a11y
description: >
  Web accessibility (WCAG 2.2 AA) — ARIA, keyboard navigation, color contrast, screen readers.
  Use when implementing accessible components, adding ARIA attributes, keyboard navigation,
  focus management, or checking contrast. Triggers: accessibility, a11y, ARIA, keyboard
  navigation, screen reader, focus trap, skip link, WCAG, contrast ratio, prefers-reduced-motion.
---

# Accessibility (a11y)

Senior accessibility engineer. WCAG 2.2 AA compliance. Semantic HTML first, ARIA second. See `web-core` skill for semantic HTML, `design-system` skill for color tokens.

## First Rule of ARIA

**Do NOT use ARIA if native HTML provides the semantics.** Native elements have built-in keyboard handling, focus management, and screen reader support.

| Instead of ARIA | Use Native HTML |
|---|---|
| `<div role="button">` | `<button>` |
| `<div role="navigation">` | `<nav>` |
| `<div role="dialog">` | `<dialog>` |
| `<span role="link">` | `<a href>` |
| `<div role="list">` | `<ul>` / `<ol>` |
| `<div role="checkbox">` | `<input type="checkbox">` |

## When ARIA Is Needed

- **Live regions**: `aria-live="polite"` for dynamic content updates
- **Expanded state**: `aria-expanded="true/false"` for disclosure widgets
- **Current state**: `aria-current="page"` for active nav link
- **Labels**: `aria-label` when visible text isn't sufficient, `aria-labelledby` to reference existing text
- **Descriptions**: `aria-describedby` for supplementary info (e.g., password requirements)

## Keyboard Navigation Patterns

```
Tab / Shift+Tab    — Move between focusable elements
Enter / Space      — Activate buttons, links
Escape             — Close modals, dropdowns
Arrow keys         — Navigate within composite widgets (tabs, menus)
```

- **Focus trap**: Keep focus inside modals — use `<dialog>` (has native trap) or `inert` attribute on background
- **Roving tabindex**: For tab panels, menus — one item has `tabindex="0"`, others `-1`, move with arrow keys
- **Skip link**: First focusable element — `<a href="#main" class="sr-only focus:not-sr-only">Skip to content</a>`
- **Focus visible**: Always style `:focus-visible` — never remove focus outlines globally

## Color & Contrast

- **WCAG AA text**: 4.5:1 contrast ratio (normal text), 3:1 (large text: 18px+ bold or 24px+)
- **UI components**: 3:1 against adjacent colors (borders, icons, form controls)
- **Never use color alone**: Always pair color with icons, text, or patterns for meaning
- **Test**: Use browser DevTools contrast checker or axe-core

## Media Queries

```css
/* Reduce motion for vestibular disorders */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}

/* Color scheme preference */
@media (prefers-color-scheme: dark) { /* dark theme */ }

/* High contrast mode */
@media (prefers-contrast: more) { /* increase contrast */ }
```

## CLI Tools

```bash
pa11y http://localhost:4321              # test single page against WCAG
pa11y-ci                                 # test multiple URLs from .pa11yci config
pa11y --standard WCAG2AA --reporter json http://localhost:4321
```

Config for `pa11y-ci` (`.pa11yci` at project root):

```json
{
  "defaults": { "standard": "WCAG2AA" },
  "urls": [
    "http://localhost:4321/",
    "http://localhost:4321/about"
  ]
}
```

## References

| Trigger | File | Purpose |
|---------|------|---------|
| dialog, tabs, accordion, focus management, live regions, screen reader testing | `references/patterns.md` | ARIA widget patterns and testing strategies |

## MUST DO

- Use semantic HTML before reaching for ARIA roles
- Include skip navigation link as first focusable element
- Ensure all interactive elements are keyboard-accessible
- Style `:focus-visible` for keyboard focus indication
- Add `alt` text to all images (empty `alt=""` for decorative)
- Test with keyboard-only navigation
- Respect `prefers-reduced-motion` in all animations

## MUST NOT

- Use ARIA roles that duplicate native HTML semantics
- Remove focus outlines (`outline: none`) without replacement
- Use color alone to convey meaning (errors, status, required fields)
- Use `tabindex` > 0 — it disrupts natural tab order
- Skip heading levels (`h1` → `h3` without `h2`)
- Auto-play audio or video without user control
- Use `title` attribute as sole accessible name — poor screen reader support
