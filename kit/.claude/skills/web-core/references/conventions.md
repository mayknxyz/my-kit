# Coding Conventions — Vanilla HTML + CSS + JavaScript

## HTML

### Semantic Structure

Use semantic elements for document structure:

```html
<header>
  <nav aria-label="Main navigation">...</nav>
</header>
<main>
  <section aria-labelledby="section-heading">
    <h2 id="section-heading">Section Title</h2>
    <article>...</article>
  </section>
</main>
<footer>...</footer>
```

### Accessibility Basics

- Every `<img>` must have a meaningful `alt` attribute (or `alt=""` for decorative images)
- Use `aria-label` or `aria-labelledby` for navigation and landmark regions
- Ensure all interactive elements are keyboard-accessible
- Maintain logical heading hierarchy (`h1` > `h2` > `h3` — no skipping)
- Use `<button>` for actions, `<a>` for navigation — never the reverse
- Provide `:focus-visible` styles for all interactive elements

### HTML Style

- 2-space indentation
- Lowercase tags and attributes
- Double quotes for attribute values
- Boolean attributes without values (`<input required>`, not `<input required="required">`)

## CSS

### BEM Naming Convention

```css
/* Block */
.card { }

/* Element */
.card__title { }
.card__body { }

/* Modifier */
.card--featured { }
.card__title--large { }
```

### Custom Properties

Define design tokens as custom properties on `:root`:

```css
:root {
  --color-primary: #2563eb;
  --color-text: #1f2937;
  --color-bg: #ffffff;
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: ui-monospace, monospace;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;
  --max-width: 72rem;
  --border-radius: 0.375rem;
}
```

### Mobile-First Responsive Design

Write base styles for mobile, then layer on larger breakpoints:

```css
.grid {
  display: grid;
  gap: var(--spacing-md);
  grid-template-columns: 1fr;
}

@media (min-width: 640px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 1024px) {
  .grid { grid-template-columns: repeat(3, 1fr); }
}
```

### CSS Property Order

1. Layout (display, position, grid/flex properties)
2. Box model (width, height, margin, padding, border)
3. Typography (font, text, color)
4. Visual (background, shadow, opacity)
5. Misc (cursor, transition, animation)

## JavaScript

### ES Modules

```html
<script type="module" src="js/main.js"></script>
```

```javascript
// js/utils.js
export function formatDate(date) {
  return new Intl.DateTimeFormat('en-US').format(date);
}

// js/main.js
import { formatDate } from './utils.js';
```

### DOM Interaction

- Cache DOM references
- Use event delegation for repeated elements
- Prefer `querySelector`/`querySelectorAll` over older APIs

```javascript
const list = document.querySelector('.item-list');

list.addEventListener('click', (event) => {
  const item = event.target.closest('.item');
  if (!item) return;
  item.classList.toggle('item--active');
});
```

### Error Handling

```javascript
async function loadData(url) {
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('[loadData]', error);
    showError('Failed to load data. Please try again.');
    return null;
  }
}
```

### JavaScript Style

- 2-space indentation
- `const` by default, `let` when reassignment is needed, never `var`
- Arrow functions for callbacks, named functions for top-level declarations
- Strict equality (`===` / `!==`)
- Template literals over string concatenation

## File Organization

```
├── index.html
├── css/
│   ├── style.css
│   ├── reset.css
│   └── components/
├── js/
│   ├── main.js
│   ├── utils.js
│   └── components/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
└── docs/
```

## Performance

- Load CSS in `<head>`, scripts with `type="module"` (deferred by default)
- Use `loading="lazy"` and `decoding="async"` on below-fold images
- Provide `width` and `height` on images to prevent layout shift
- Use `<picture>` with `srcset` for responsive images and modern formats (WebP, AVIF)
- Prefer CSS transitions/animations over JavaScript animation
- Avoid layout thrashing — batch DOM reads and writes
