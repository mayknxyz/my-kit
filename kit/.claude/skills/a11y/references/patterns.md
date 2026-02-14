# Accessibility Patterns

Reusable ARIA widget patterns, focus management recipes, and testing strategies.

## Skip Link

First focusable element on every page:

```html
<a href="#main" class="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:bg-white focus:px-4 focus:py-2 focus:rounded focus:shadow-lg">
  Skip to content
</a>
```

## Disclosure Widget (Accordion)

```html
<div>
  <button
    aria-expanded="false"
    aria-controls="panel-1"
    id="trigger-1"
  >
    Section Title
  </button>
  <div
    id="panel-1"
    role="region"
    aria-labelledby="trigger-1"
    hidden
  >
    Panel content
  </div>
</div>
```

```ts
// Toggle logic
button.addEventListener("click", () => {
  const expanded = button.getAttribute("aria-expanded") === "true";
  button.setAttribute("aria-expanded", String(!expanded));
  panel.hidden = expanded;
});
```

## Tab Panel

```html
<div role="tablist" aria-label="Settings">
  <button role="tab" id="tab-1" aria-selected="true" aria-controls="tabpanel-1" tabindex="0">
    General
  </button>
  <button role="tab" id="tab-2" aria-selected="false" aria-controls="tabpanel-2" tabindex="-1">
    Advanced
  </button>
</div>

<div role="tabpanel" id="tabpanel-1" aria-labelledby="tab-1" tabindex="0">
  General settings content
</div>
<div role="tabpanel" id="tabpanel-2" aria-labelledby="tab-2" tabindex="0" hidden>
  Advanced settings content
</div>
```

Keyboard handling — arrow keys move between tabs, Tab moves into panel:

```ts
tablist.addEventListener("keydown", (e) => {
  const tabs = [...tablist.querySelectorAll("[role=tab]")];
  const index = tabs.indexOf(e.target as HTMLElement);

  let next: number | null = null;
  if (e.key === "ArrowRight") next = (index + 1) % tabs.length;
  if (e.key === "ArrowLeft") next = (index - 1 + tabs.length) % tabs.length;
  if (e.key === "Home") next = 0;
  if (e.key === "End") next = tabs.length - 1;

  if (next !== null) {
    e.preventDefault();
    activateTab(tabs[next]);
  }
});

function activateTab(tab: HTMLElement) {
  const tablist = tab.closest("[role=tablist]")!;
  tablist.querySelectorAll("[role=tab]").forEach((t) => {
    t.setAttribute("aria-selected", "false");
    t.setAttribute("tabindex", "-1");
    document.getElementById(t.getAttribute("aria-controls")!)!.hidden = true;
  });
  tab.setAttribute("aria-selected", "true");
  tab.setAttribute("tabindex", "0");
  tab.focus();
  document.getElementById(tab.getAttribute("aria-controls")!)!.hidden = false;
}
```

## Modal Dialog

Prefer native `<dialog>` — it handles focus trapping, Escape to close, and `inert` on background:

```html
<dialog id="confirm-dialog" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Action</h2>
  <p>Are you sure you want to proceed?</p>
  <div>
    <button data-action="cancel">Cancel</button>
    <button data-action="confirm" autofocus>Confirm</button>
  </div>
</dialog>
```

```ts
const dialog = document.getElementById("confirm-dialog") as HTMLDialogElement;

// Open — showModal() traps focus automatically
dialog.showModal();

// Close — returns focus to the element that opened it
dialog.addEventListener("close", () => {
  triggerButton.focus();
});

// Close on backdrop click
dialog.addEventListener("click", (e) => {
  if (e.target === dialog) dialog.close();
});
```

## Live Regions

For dynamic content updates (form submission results, notifications):

```html
<!-- Polite: announced after current speech -->
<div aria-live="polite" aria-atomic="true" class="sr-only">
  <!-- Inject status text here -->
</div>

<!-- Assertive: interrupts current speech (use sparingly) -->
<div aria-live="assertive" role="alert">
  <!-- Inject error messages here -->
</div>
```

Pattern for form submission feedback:

```ts
const statusRegion = document.querySelector("[aria-live='polite']")!;

async function handleSubmit() {
  statusRegion.textContent = "Sending message...";

  try {
    await submitForm();
    statusRegion.textContent = "Message sent successfully.";
  } catch {
    statusRegion.textContent = "Failed to send message. Please try again.";
  }
}
```

## Focus Management

### After Route Navigation

Move focus to the main heading after client-side navigation:

```ts
function announcePageChange(title: string) {
  document.title = title;
  const heading = document.querySelector("h1");
  if (heading) {
    heading.setAttribute("tabindex", "-1");
    heading.focus();
  }
}
```

### After Dynamic Content Load

When new content appears (infinite scroll, tabs), move focus to the first new item:

```ts
function focusNewContent(container: HTMLElement) {
  const firstFocusable = container.querySelector<HTMLElement>(
    "a, button, input, [tabindex='0']"
  );
  if (firstFocusable) firstFocusable.focus();
}
```

## Screen Reader Testing

### Quick Manual Tests

1. **Tab through page** — can you reach and operate every interactive element?
2. **Screen reader** — does every element announce its role, name, and state?
3. **Landmarks** — are `<main>`, `<nav>`, `<header>`, `<footer>` present?
4. **Headings** — does the heading hierarchy make sense? (h1 → h2 → h3, no skips)
5. **Forms** — is every input labeled? Are errors announced?
6. **Images** — do all images have appropriate `alt` text?

### Automated Testing

```bash
# pa11y for WCAG compliance
pa11y http://localhost:4321 --standard WCAG2AA

# axe-core via Playwright
npx playwright test --grep a11y
```

```ts
// Playwright + axe-core
import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test("homepage has no a11y violations", async ({ page }) => {
  await page.goto("/");
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```
