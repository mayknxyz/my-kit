# Testing Patterns

Reusable test configurations, fixtures, and patterns for Vitest and Playwright.

## Vitest Configuration Recipes

### Astro + Svelte Project

```ts
// vitest.config.ts
import { getViteConfig } from "astro/config";

export default getViteConfig({
  test: {
    environment: "happy-dom",
    globals: true,
    include: ["src/**/*.test.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      include: ["src/**/*.ts"],
      exclude: ["src/**/*.test.ts", "src/**/*.d.ts"],
    },
  },
});
```

### Pure TypeScript Library

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      thresholds: { branches: 80, functions: 80, lines: 80 },
    },
  },
});
```

## Test File Organization

```
src/
├── lib/
│   ├── utils.ts
│   └── utils.test.ts          # Co-located unit test
├── components/
│   ├── ContactForm.svelte
│   └── ContactForm.test.ts    # Component test
tests/
├── e2e/
│   ├── contact.spec.ts        # E2E test
│   └── fixtures/
│       └── contact.ts         # Page object
└── setup.ts                   # Global test setup
```

## Testing Utilities

### Factory Functions

```ts
// tests/factories.ts
function createUser(overrides: Partial<User> = {}): User {
  return {
    id: "user-1",
    name: "Test User",
    email: "test@example.com",
    ...overrides,
  };
}

function createPost(overrides: Partial<Post> = {}): Post {
  return {
    id: "post-1",
    title: "Test Post",
    slug: "test-post",
    body: "Test content",
    publishedAt: new Date("2026-01-01"),
    ...overrides,
  };
}
```

### Mock API Responses

```ts
// tests/mocks.ts
function mockFetchResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function mockFormData(fields: Record<string, string>): FormData {
  const form = new FormData();
  for (const [key, value] of Object.entries(fields)) {
    form.append(key, value);
  }
  return form;
}
```

## Playwright Setup

### Configuration

```ts
// playwright.config.ts
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "tests/e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  webServer: {
    command: "npm run preview",
    port: 4321,
    reuseExistingServer: !process.env.CI,
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "mobile", use: { ...devices["Pixel 5"] } },
  ],
});
```

### Page Object Pattern

```ts
// tests/e2e/fixtures/contact.ts
import type { Page, Locator } from "@playwright/test";

export class ContactPage {
  readonly nameInput: Locator;
  readonly emailInput: Locator;
  readonly messageInput: Locator;
  readonly submitButton: Locator;
  readonly successMessage: Locator;
  readonly errorMessage: Locator;

  constructor(private page: Page) {
    this.nameInput = page.getByRole("textbox", { name: "Name" });
    this.emailInput = page.getByRole("textbox", { name: "Email" });
    this.messageInput = page.getByRole("textbox", { name: "Message" });
    this.submitButton = page.getByRole("button", { name: /send/i });
    this.successMessage = page.getByRole("status");
    this.errorMessage = page.getByRole("alert");
  }

  async goto() {
    await this.page.goto("/contact");
  }

  async fill(name: string, email: string, message: string) {
    await this.nameInput.fill(name);
    await this.emailInput.fill(email);
    await this.messageInput.fill(message);
  }

  async submit() {
    await this.submitButton.click();
  }
}
```

### Using Page Objects in Tests

```ts
// tests/e2e/contact.spec.ts
import { test, expect } from "@playwright/test";
import { ContactPage } from "./fixtures/contact";

test.describe("Contact form", () => {
  let contact: ContactPage;

  test.beforeEach(async ({ page }) => {
    contact = new ContactPage(page);
    await contact.goto();
  });

  test("submits successfully with valid data", async () => {
    await contact.fill("Jane Doe", "jane@example.com", "Hello world!");
    await contact.submit();
    await expect(contact.successMessage).toBeVisible();
  });

  test("shows error for invalid email", async () => {
    await contact.fill("Jane Doe", "not-an-email", "Hello world!");
    await contact.submit();
    await expect(contact.errorMessage).toBeVisible();
  });
});
```

## Common Assertion Patterns

```ts
// Zod schema validation tests
import { describe, it, expect } from "vitest";

describe("ContactSchema", () => {
  it("accepts valid input", () => {
    const result = ContactSchema.safeParse({
      name: "Jane",
      email: "jane@example.com",
      message: "Hello world!",
    });
    expect(result.success).toBe(true);
  });

  it("rejects missing required fields", () => {
    const result = ContactSchema.safeParse({});
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.flatten().fieldErrors).toHaveProperty("name");
      expect(result.error.flatten().fieldErrors).toHaveProperty("email");
    }
  });

  it("strips HTML from text fields", () => {
    const result = ContactSchema.safeParse({
      name: "<script>alert('xss')</script>Jane",
      email: "jane@example.com",
      message: "Hello <b>world</b>!",
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.name).toBe("alert('xss')Jane");
      expect(result.data.message).toBe("Hello world!");
    }
  });
});
```
