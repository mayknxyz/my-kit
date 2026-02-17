---
name: zod
description: >
  Zod schema validation — composition, coercion, discriminated unions, error handling, type
  inference. Use when writing validation schemas, parsing form data, or defining API contracts.
  Triggers: Zod, z.object, z.string, schema validation, safeParse, z.infer, z.coerce,
  discriminated union, form validation.
---

# Zod

Senior Zod engineer. Runtime validation + static types. See `api-design` skill for API validation patterns, `astro` skill for content collection schemas.

## Schema Composition

```ts
import { z } from "zod";

// Base schema
const BaseSchema = z.object({
  id: z.string().uuid(),
  createdAt: z.coerce.date(),
});

// Extend
const UserSchema = BaseSchema.extend({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  role: z.enum(["admin", "user"]),
});

// Pick / Omit
const CreateUserSchema = UserSchema.omit({ id: true, createdAt: true });
const UserSummary = UserSchema.pick({ id: true, name: true, email: true });

// Merge (combine two schemas)
const WithTimestamps = z.object({ updatedAt: z.coerce.date() });
const FullUser = UserSchema.merge(WithTimestamps);
```

## Coercion for Form Data

Forms submit strings. Use `z.coerce.*` to auto-convert:

```ts
const FormSchema = z.object({
  age: z.coerce.number().int().positive(),
  startDate: z.coerce.date(),
  active: z.coerce.boolean(),
  score: z.coerce.number().min(0).max(100),
});
```

## Discriminated Unions

```ts
const EventSchema = z.discriminatedUnion("type", [
  z.object({ type: z.literal("click"), x: z.number(), y: z.number() }),
  z.object({ type: z.literal("keypress"), key: z.string() }),
  z.object({ type: z.literal("scroll"), offset: z.number() }),
]);
```

## Error Handling

```ts
// Always use safeParse in APIs (no throw)
const result = schema.safeParse(input);

if (!result.success) {
  const fieldErrors = result.error.flatten().fieldErrors;
  // { email: ["Invalid email"], name: ["Required"] }
  return Response.json(
    { error: "Validation failed", code: "VALIDATION_ERROR", details: fieldErrors },
    { status: 400 }
  );
}

// result.data is fully typed
const user = result.data;
```

### Custom Error Messages

```ts
z.string()
  .min(1, "Name is required")
  .max(100, "Name must be under 100 characters");

z.string().email("Please enter a valid email address");
```

## Type Inference

```ts
const UserSchema = z.object({
  name: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;
// { name: string; email: string }

// Use for function params, API responses, etc.
function createUser(data: z.infer<typeof CreateUserSchema>) { ... }
```

## Common Patterns

```ts
// Optional with default
z.string().optional().default("untitled")

// Nullable
z.string().nullable()

// Transform
z.string().transform((s) => s.trim().toLowerCase())

// Refine (custom validation)
z.string().refine((s) => s.includes("@"), "Must contain @")

// Array with constraints
z.array(z.string()).min(1).max(10)

// Record (dynamic keys)
z.record(z.string(), z.number())
```

## Form Input Sanitization

Strip HTML from plain-text form fields using `.transform()`. This prevents stored XSS when input is forwarded to external services (webhooks, CRMs, email). See `security` skill for full sanitization strategy.

```ts
const ContactSchema = z.object({
  name: z.string().min(1).max(100).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")),
  email: z.string().email().max(255).toLowerCase(),
  message: z.string().min(10).max(5000).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")),
  phone: z.string().max(20).regex(/^[0-9+\-() ]*$/).optional(),
  company: z.string().max(200).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")).optional(),
});

type ContactInput = z.infer<typeof ContactSchema>;
```

**Key points:**

- `.transform()` runs **after** validation — types stay clean (`z.infer` produces `string`, not `string | undefined`)
- `.max()` limits prevent DoS via oversized payloads
- `.regex()` on phone acts as a character allowlist — stricter than HTML stripping
- Pair with `safeParse()` in the API handler (see `api-design` skill)

## MUST DO

- Use `safeParse()` in API routes and form handlers (no uncaught throws)
- Use `z.coerce.date()` for date strings (forms, content collections)
- Use `z.coerce.number()` for form number inputs
- Infer TypeScript types with `z.infer<typeof Schema>`
- Use `.flatten().fieldErrors` for user-friendly validation messages
- Use `z.discriminatedUnion()` for tagged union types
- Set `.max()` length limits on all string fields (DoS prevention)
- Use `.transform()` to strip HTML from plain-text form fields

## MUST NOT

- Use `z.date()` for string date inputs — use `z.coerce.date()`
- Use `parse()` without `try/catch` in API handlers — use `safeParse()`
- Duplicate type definitions — infer from Zod schemas with `z.infer`
- Skip custom error messages for user-facing validation
- Use `.passthrough()` without understanding it passes unknown keys through
