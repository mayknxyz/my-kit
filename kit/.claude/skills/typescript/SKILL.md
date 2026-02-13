---
name: typescript
description: >
  TypeScript strict-mode patterns, type narrowing, and modern idioms. Use when writing types,
  interfaces, generics, discriminated unions, or configuring TypeScript. Triggers: TypeScript,
  .ts files, types, interfaces, generics, type narrowing, satisfies, as const, utility types,
  tsconfig, strict mode.
---

# TypeScript

Senior TypeScript engineer. Strict mode always. Types as documentation. See `zod` skill for runtime validation.

## Key Patterns

### `satisfies` Operator (Validate Without Widening)

```ts
const routes = {
  home: "/",
  about: "/about",
  blog: "/blog",
} satisfies Record<string, string>;
// Type: { home: "/"; about: "/about"; blog: "/blog" } — NOT Record<string, string>
```

### `as const` Over Enums

```ts
const Status = { Active: "active", Inactive: "inactive" } as const;
type Status = (typeof Status)[keyof typeof Status]; // "active" | "inactive"
```

### Discriminated Unions + Exhaustive Checks

```ts
type Result<T> = { ok: true; data: T } | { ok: false; error: string };

function handle<T>(result: Result<T>) {
  if (result.ok) return result.data; // narrowed
  throw new Error(result.error);
}

// Exhaustive check helper
function exhaustive(value: never): never {
  throw new Error(`Unhandled: ${value}`);
}
```

### Generic Constraints

```ts
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

### Utility Types

- `Pick<T, K>` / `Omit<T, K>` — select/exclude properties
- `Partial<T>` / `Required<T>` — make all optional/required
- `Record<K, V>` — object with known key type
- `Extract<T, U>` / `Exclude<T, U>` — filter union members
- `ReturnType<T>` / `Parameters<T>` — extract function signatures
- `NonNullable<T>` — remove `null | undefined`

### `interface` vs `type`

- Use `interface` for object shapes that may be extended (component props, API responses)
- Use `type` for unions, intersections, mapped types, and aliases

## MUST DO

- Enable `strict: true` in tsconfig (includes `strictNullChecks`, `noImplicitAny`)
- Use `unknown` instead of `any`, then narrow with type guards
- Use `satisfies` to validate object literals while preserving literal types
- Use `as const` objects over enums for string constants
- Use discriminated unions for state modeling
- Add exhaustive checks in switch/if chains on union types

## MUST NOT

- Use `any` — use `unknown` and narrow with type guards or assertions
- Use `enum` — use `as const` objects with derived union types
- Use `!` non-null assertion unless you've verified the value exists
- Cast with `as` to bypass type errors — fix the underlying type instead
- Use `Function` type — use specific signatures like `() => void`
- Ignore `strict` mode errors — fix them properly

Docs: https://www.typescriptlang.org/docs
