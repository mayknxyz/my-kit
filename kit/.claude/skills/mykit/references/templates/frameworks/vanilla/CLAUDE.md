# CLAUDE.md

Instructions for Claude Code when working in this repository.

## Project Overview

This is a vanilla HTML, CSS, and JavaScript project with no build tools or framework dependencies.

## Tech Stack

- **HTML5** — semantic markup
- **CSS3** — modern CSS (custom properties, flexbox, grid)
- **JavaScript** — vanilla ES modules, no transpilation

## Project Structure

```
├── index.html
├── css/
│   └── style.css
├── js/
│   └── main.js
├── assets/
│   ├── images/
│   └── fonts/
└── docs/
```

## Development Guidelines

- Use semantic HTML elements (`<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`)
- Use CSS custom properties for theming (`--color-primary`, `--spacing-md`, etc.)
- Use ES modules with `type="module"` on script tags
- No build step required — files are served directly
- Keep JavaScript minimal and progressive-enhancement friendly

## Code Style

- HTML: 2-space indentation, lowercase tags and attributes, double quotes for attribute values
- CSS: 2-space indentation, BEM naming convention (`.block__element--modifier`), mobile-first media queries
- JavaScript: 2-space indentation, `const`/`let` (no `var`), arrow functions preferred, strict mode

## Browser Support

Target modern evergreen browsers (Chrome, Firefox, Safari, Edge — latest 2 versions).

## Testing

- Manual browser testing
- Validate HTML with W3C validator
- Check accessibility with axe or Lighthouse
