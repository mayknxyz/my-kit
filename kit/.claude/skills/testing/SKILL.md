---
name: testing
description: >
  Testing with Vitest, Playwright, and Testing Library. Use when writing unit tests, E2E tests,
  component tests, or configuring test runners. Triggers: testing, Vitest, Playwright, Testing
  Library, unit test, E2E, integration test, coverage, mocking, happy-dom, page objects.
---

# Testing

Senior test engineer. Vitest for unit/integration. Playwright for E2E. Testing Library for component queries. See `astro` skill for Astro component testing.

## Vitest

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "happy-dom", // or "jsdom" for DOM tests
    globals: true,
    coverage: { provider: "v8", reporter: ["text", "html"] },
  },
});
```

### Key Patterns

```ts
import { describe, it, expect, vi, beforeEach } from "vitest";

// Mocking
vi.mock("./api", () => ({ fetchData: vi.fn() }));
const mockFetch = vi.mocked(fetchData);
mockFetch.mockResolvedValue({ data: "test" });

// Async testing — always await
it("fetches data", async () => {
  const result = await fetchData();
  expect(result.data).toBe("test");
});

// Spies
const spy = vi.spyOn(object, "method");
expect(spy).toHaveBeenCalledWith("arg");

// Snapshot (use sparingly)
expect(result).toMatchSnapshot();
```

## Playwright (E2E)

```ts
import { test, expect } from "@playwright/test";

test("contact form submits", async ({ page }) => {
  await page.goto("/contact");
  await page.getByRole("textbox", { name: "Email" }).fill("test@example.com");
  await page.getByRole("textbox", { name: "Message" }).fill("Hello");
  await page.getByRole("button", { name: "Send" }).click();
  await expect(page.getByText("Message sent")).toBeVisible();
});
```

### Selector Priority

1. `getByRole` — accessible role + name (best)
2. `getByLabel` — form elements by label
3. `getByPlaceholder` — form inputs
4. `getByText` — visible text content
5. `getByTestId` — last resort

### Page Object Pattern

```ts
class ContactPage {
  constructor(private page: Page) {}
  async fill(email: string, message: string) {
    await this.page.getByRole("textbox", { name: "Email" }).fill(email);
    await this.page.getByRole("textbox", { name: "Message" }).fill(message);
  }
  async submit() {
    await this.page.getByRole("button", { name: "Send" }).click();
  }
}
```

## Testing Library

```ts
import { render, screen } from "@testing-library/svelte";
import userEvent from "@testing-library/user-event";

it("toggles menu", async () => {
  const user = userEvent.setup();
  render(Menu);
  await user.click(screen.getByRole("button", { name: "Menu" }));
  expect(screen.getByRole("navigation")).toBeVisible();
});
```

## References

| Trigger | File | Purpose |
|---------|------|---------|
| Vitest config, Playwright setup, page objects, test factories, test organization | `references/patterns.md` | Test configurations, fixtures, and patterns |

## MUST DO

- Use `getByRole` as the primary query method (mirrors accessibility)
- Use `userEvent` over `fireEvent` (simulates real user behavior)
- Always `await` async assertions and interactions
- Use `vi.mock()` for module-level mocks, `vi.spyOn()` for method mocks
- Test behavior, not implementation details
- Use `happy-dom` for Astro component tests

## MUST NOT

- Use `getByTestId` as first choice — prefer accessible queries
- Test implementation details (internal state, private methods)
- Skip `await` on async operations — leads to false positives
- Use `fireEvent` when `userEvent` is available
- Write tests that depend on execution order
- Mock everything — prefer integration tests over excessive mocking
