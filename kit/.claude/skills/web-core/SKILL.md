---
name: web-core
description: >
  Modern HTML, CSS, and vanilla JavaScript fundamentals. Use when writing semantic HTML,
  modern CSS features, or vanilla JS patterns. Triggers: semantic HTML, CSS nesting,
  container queries, :has(), @layer, light-dark(), custom elements, IntersectionObserver,
  event delegation, progressive enhancement, Web APIs.
---

# Web Core

Senior web platform engineer. Semantic HTML first. Modern CSS. Progressive enhancement. See `tailwind` skill for utility CSS, `a11y` skill for accessibility, `performance` skill for optimization.

## Semantic HTML

| Instead of | Use | When |
|---|---|---|
| `<div>` wrapper | `<section>`, `<article>`, `<aside>`, `<nav>` | Meaningful content grouping |
| `<div>` clickable | `<button>` or `<a>` | Interactive elements |
| `<div>` list | `<ul>`, `<ol>`, `<dl>` | Lists, term-definition pairs |
| `<b>`, `<i>` | `<strong>`, `<em>` | Semantic emphasis |
| `<div>` heading | `<h1>`–`<h6>` | Headings in hierarchy |
| `<div>` form group | `<fieldset>` + `<legend>` | Related form controls |
| `<div>` dialog | `<dialog>` | Modal/non-modal dialogs |
| `<div>` details | `<details>` + `<summary>` | Expandable content |

## Modern CSS

```css
/* Nesting (native) */
.card {
  padding: 1rem;
  & .title { font-weight: bold; }
  &:hover { background: var(--color-surface-hover); }
}

/* :has() — parent selector */
.form:has(:invalid) { border-color: var(--color-error); }

/* Container queries */
@container card (min-width: 400px) {
  .card-body { flex-direction: row; }
}

/* @layer for cascade control */
@layer base, components, utilities;

/* light-dark() — theme-aware values */
color: light-dark(var(--color-gray-900), var(--color-gray-100));

/* Logical properties */
margin-inline: auto;    /* replaces margin-left/right */
padding-block: 1rem;    /* replaces padding-top/bottom */
```

## Vanilla JS Patterns

```js
// Event delegation
document.querySelector(".list").addEventListener("click", (e) => {
  const item = e.target.closest("[data-action]");
  if (item) handleAction(item.dataset.action);
});

// IntersectionObserver (lazy load, animations)
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) entry.target.classList.add("visible");
  });
}, { threshold: 0.1 });

// Custom element
class MyComponent extends HTMLElement {
  connectedCallback() { this.innerHTML = `<p>Hello</p>`; }
}
customElements.define("my-component", MyComponent);
```

## CLI Tools

```bash
# Offline HTML5 validation
html-validate dist/**/*.html
html-validate --config .htmlvalidate.json src/
```

## MUST DO

- Use semantic HTML elements before reaching for `<div>` or `<span>`
- Use native `<dialog>` for modals (with `.showModal()` / `.close()`)
- Use `<details>` / `<summary>` for expandable content
- Use CSS nesting, `:has()`, and container queries where supported
- Use logical properties (`inline`, `block`) over physical (`left`, `right`)
- Use event delegation for dynamic lists
- Use `<template>` element for client-side HTML templating

## References

| Topic | File | Load When |
|-------|------|-----------|
| Coding conventions | [conventions.md](references/conventions.md) | HTML semantics, CSS patterns, JS modules, file organization |

## MUST NOT

- Use `<div>` for everything — choose semantic elements first
- Use `float` for layout — use flexbox or grid
- Use `var` keyword — use `const` and `let`
- Use `document.write()` — use DOM APIs
- Use inline styles for theming — use CSS custom properties
- Use `onclick` HTML attributes — use `addEventListener` (in vanilla JS context)
