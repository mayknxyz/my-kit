# TypeScript Advanced Patterns

## Conditional Types

### `infer` Keyword

Extract types from other types:

```ts
// Extract return type of a promise
type Awaited<T> = T extends Promise<infer U> ? U : T;

// Extract array element type
type ElementOf<T> = T extends (infer U)[] ? U : never;

// Extract function parameter types
type FirstParam<T> = T extends (first: infer F, ...rest: any[]) => any ? F : never;
```

### Recursive Conditional Types

```ts
// Deep readonly — makes nested objects immutable
type DeepReadonly<T> = T extends (infer U)[]
  ? readonly DeepReadonly<U>[]
  : T extends object
    ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
    : T;

// Deep partial — makes all nested properties optional
type DeepPartial<T> = T extends object
  ? { [K in keyof T]?: DeepPartial<T[K]> }
  : T;
```

## Mapped Types

### Property Transformers

```ts
// Make all properties nullable
type Nullable<T> = { [K in keyof T]: T[K] | null };

// Make specific properties required
type RequireKeys<T, K extends keyof T> = T & Required<Pick<T, K>>;

// Readonly except specific keys
type ReadonlyExcept<T, K extends keyof T> = Readonly<Omit<T, K>> & Pick<T, K>;
```

### Key Remapping

```ts
// Prefix all keys with "on" and capitalize
type EventMap<T> = {
  [K in keyof T as `on${Capitalize<string & K>}`]: (value: T[K]) => void;
};

interface User { name: string; age: number }
type UserEvents = EventMap<User>;
// { onName: (value: string) => void; onAge: (value: number) => void }

// Filter keys by value type
type StringKeys<T> = {
  [K in keyof T as T[K] extends string ? K : never]: T[K];
};
```

## Template Literal Types

### String Manipulation at Type Level

```ts
// Route parameter extraction
type ExtractParams<T extends string> =
  T extends `${string}:${infer Param}/${infer Rest}`
    ? Param | ExtractParams<Rest>
    : T extends `${string}:${infer Param}`
      ? Param
      : never;

type Params = ExtractParams<"/users/:id/posts/:postId">;
// "id" | "postId"

// CSS unit types
type CSSUnit = "px" | "rem" | "em" | "%" | "vh" | "vw";
type CSSValue = `${number}${CSSUnit}`;
const width: CSSValue = "100px"; // OK
```

### Event Name Types

```ts
type EventName = `${"click" | "change" | "submit"}_${string}`;
// Matches: "click_button", "change_input", "submit_form"
```

## Module Augmentation

Extend third-party library types without modifying source:

```ts
// Extend Astro's global types
declare namespace App {
  interface Locals {
    userId: string;
    isAdmin: boolean;
  }
}

// Extend a library's module
declare module "some-library" {
  interface Config {
    customOption: string;
  }
}

// Add global window properties
declare global {
  interface Window {
    umami: {
      track: (event: string, data?: Record<string, string>) => void;
    };
  }
}
```

## Type-Safe Event Emitters

```ts
type EventMap = {
  "user:login": { userId: string; timestamp: number };
  "user:logout": { userId: string };
  "page:view": { path: string; referrer?: string };
};

class TypedEmitter<Events extends Record<string, unknown>> {
  private listeners = new Map<string, Set<Function>>();

  on<K extends keyof Events>(
    event: K,
    handler: (payload: Events[K]) => void
  ): void {
    const set = this.listeners.get(event as string) ?? new Set();
    set.add(handler);
    this.listeners.set(event as string, set);
  }

  emit<K extends keyof Events>(event: K, payload: Events[K]): void {
    this.listeners.get(event as string)?.forEach((fn) => fn(payload));
  }
}

const bus = new TypedEmitter<EventMap>();
bus.on("user:login", ({ userId }) => console.log(userId)); // typed
bus.emit("page:view", { path: "/" }); // typed
```

## Branded Types

Nominal typing for values that share a primitive type but have different semantics:

```ts
// Create a brand
type Brand<T, B extends string> = T & { readonly __brand: B };

// Define branded types
type UserId = Brand<string, "UserId">;
type PostId = Brand<string, "PostId">;
type USD = Brand<number, "USD">;
type EUR = Brand<number, "EUR">;

// Constructor functions
const UserId = (id: string) => id as UserId;
const PostId = (id: string) => id as PostId;
const USD = (amount: number) => amount as USD;

// Type safety — can't mix up IDs
function getUser(id: UserId): void { /* ... */ }
getUser(UserId("abc")); // OK
// getUser(PostId("abc")); // Error: PostId is not assignable to UserId

// Can't accidentally mix currencies
function chargeUSD(amount: USD): void { /* ... */ }
chargeUSD(USD(9.99)); // OK
// chargeUSD(EUR(9.99)); // Error
```

### Branded Type Utilities

```ts
// Validate and brand in one step
function parseUserId(input: string): UserId {
  if (!/^usr_[a-z0-9]+$/.test(input)) {
    throw new Error(`Invalid user ID: ${input}`);
  }
  return input as UserId;
}
```
