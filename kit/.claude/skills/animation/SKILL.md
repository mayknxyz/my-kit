---
name: animation
description: >
  Web animation — CSS transitions, keyframes, scroll-driven animations, reduced motion.
  Use when adding animations, transitions, scroll effects, or motion design. Triggers:
  animation, transition, keyframes, scroll-driven animation, prefers-reduced-motion,
  Web Animations API, fade, slide, stagger, transform, opacity.
---

# Animation

Senior animation engineer. Performance-first. Reduced motion always. See `a11y` skill for accessibility, `performance` skill for rendering performance.

## CSS Transitions vs Animations

| Use | When |
|---|---|
| `transition` | Simple state changes (hover, focus, open/close) |
| `@keyframes` | Complex multi-step animations, looping |
| Web Animations API | Dynamic, JS-controlled animations |
| Scroll-driven | Progress tied to scroll position |

## Common Patterns

```css
/* Fade in */
.fade-in {
  animation: fade-in 0.3s ease-out;
}
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Slide up */
.slide-up {
  animation: slide-up 0.4s ease-out;
}
@keyframes slide-up {
  from { opacity: 0; transform: translateY(1rem); }
  to { opacity: 1; transform: translateY(0); }
}

/* Scale on hover */
.hover-scale {
  transition: transform 0.2s ease;
  &:hover { transform: scale(1.05); }
}

/* Stagger children */
.stagger > * {
  animation: fade-in 0.3s ease-out both;
}
.stagger > *:nth-child(1) { animation-delay: 0ms; }
.stagger > *:nth-child(2) { animation-delay: 75ms; }
.stagger > *:nth-child(3) { animation-delay: 150ms; }
.stagger > *:nth-child(4) { animation-delay: 225ms; }
```

## Scroll-Driven Animations

```css
/* Progress bar tied to page scroll */
.scroll-progress {
  animation: grow-width linear;
  animation-timeline: scroll();
}
@keyframes grow-width {
  from { transform: scaleX(0); }
  to { transform: scaleX(1); }
}

/* Element reveal on scroll into view */
.reveal {
  animation: slide-up linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 100%;
}
```

## Performance Rules

Only animate **composite properties** — these skip layout and paint:

| Safe to Animate | Causes Layout/Paint |
|---|---|
| `transform` | `width`, `height` |
| `opacity` | `top`, `left`, `right`, `bottom` |
| `filter` | `margin`, `padding` |
| `clip-path` | `border`, `font-size` |

Use `will-change` sparingly and only on elements about to animate:

```css
.about-to-animate { will-change: transform, opacity; }
```

## Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

## MUST DO

- Respect `prefers-reduced-motion` in every animation
- Only animate `transform` and `opacity` for smooth 60fps
- Use `ease-out` for entrances, `ease-in` for exits
- Keep animations short: 150-400ms for UI, up to 1s for decorative
- Use CSS transitions for simple state changes
- Test animations at 0.5x speed to check smoothness

## MUST NOT

- Animate `width`, `height`, `top`, `left` — use `transform` instead
- Skip `prefers-reduced-motion` — vestibular disorders are real
- Use animation for critical content (it may be invisible with reduced motion)
- Overuse `will-change` — it consumes memory
- Create animations longer than 1s for UI interactions
- Auto-play looping animations without user control
