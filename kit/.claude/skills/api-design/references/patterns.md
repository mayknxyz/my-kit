# API Design Patterns

Reusable patterns for Cloudflare Pages API routes — error handling, pagination, and rate limiting.

## API Route Boilerplate

Standard Astro API route with validation and error handling:

```ts
// src/pages/api/contacts.ts
import type { APIContext } from "astro";
import { z } from "zod";

const ContactSchema = z.object({
  name: z.string().min(1).max(100).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")),
  email: z.string().email().max(255).toLowerCase(),
  message: z.string().min(10).max(5000).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")),
});

export async function POST({ request }: APIContext) {
  const body = await request.json().catch(() => null);

  if (!body) {
    return Response.json(
      { error: "Invalid JSON", code: "PARSE_ERROR" },
      { status: 400 },
    );
  }

  const result = ContactSchema.safeParse(body);

  if (!result.success) {
    return Response.json(
      {
        error: "Validation failed",
        code: "VALIDATION_ERROR",
        details: result.error.flatten().fieldErrors,
      },
      { status: 400 },
    );
  }

  // Process result.data...
  return Response.json({ success: true }, { status: 201 });
}
```

## Error Response Helper

Consistent error responses across all routes:

```ts
// src/lib/api-errors.ts
type ErrorCode =
  | "PARSE_ERROR"
  | "VALIDATION_ERROR"
  | "NOT_FOUND"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "CONFLICT"
  | "RATE_LIMITED"
  | "INTERNAL_ERROR";

function apiError(
  error: string,
  code: ErrorCode,
  status: number,
  details?: Record<string, string[]>,
): Response {
  return Response.json(
    { error, code, ...(details && { details }) },
    { status },
  );
}

// Usage
return apiError("Contact not found", "NOT_FOUND", 404);
return apiError("Validation failed", "VALIDATION_ERROR", 400, fieldErrors);
```

## Cursor-Based Pagination

```ts
// src/lib/pagination.ts
import { z } from "zod";

const PaginationSchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

interface PaginatedResult<T> {
  data: T[];
  cursor: string | null;
  hasMore: boolean;
}

function paginate<T extends { id: string }>(
  items: T[],
  limit: number,
): PaginatedResult<T> {
  const hasMore = items.length > limit;
  const data = hasMore ? items.slice(0, limit) : items;
  const cursor = hasMore ? data[data.length - 1].id : null;

  return { data, cursor, hasMore };
}
```

### D1 Cursor Query

```ts
async function getItems(
  db: D1Database,
  cursor?: string,
  limit = 20,
): Promise<PaginatedResult<Item>> {
  const query = cursor
    ? "SELECT * FROM items WHERE id > ? ORDER BY id LIMIT ?"
    : "SELECT * FROM items ORDER BY id LIMIT ?";

  const params = cursor ? [cursor, limit + 1] : [limit + 1];
  const { results } = await db.prepare(query).bind(...params).all<Item>();

  return paginate(results, limit);
}
```

## Turnstile Verification

Bot protection for form submissions:

```ts
async function verifyTurnstile(
  token: string,
  secret: string,
  ip?: string,
): Promise<boolean> {
  const response = await fetch(
    "https://challenges.cloudflare.com/turnstile/v0/siteverify",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        secret,
        response: token,
        ...(ip && { remoteip: ip }),
      }),
    },
  );

  const result = await response.json<{ success: boolean }>();
  return result.success;
}

// In API route
const turnstileToken = body["cf-turnstile-response"];
if (!turnstileToken || !await verifyTurnstile(turnstileToken, env.TURNSTILE_SECRET)) {
  return apiError("Bot verification failed", "FORBIDDEN", 403);
}
```

## Method Router

Handle multiple HTTP methods in one file:

```ts
// src/pages/api/posts/[id].ts
import type { APIContext } from "astro";

export async function GET({ params }: APIContext) {
  // Fetch single post
}

export async function PUT({ params, request }: APIContext) {
  // Update post
}

export async function DELETE({ params }: APIContext) {
  // Delete post
  return new Response(null, { status: 204 });
}
```

## Request Logging Pattern

Lightweight logging for debugging API routes in development:

```ts
function logRequest(request: Request, status: number, durationMs: number) {
  if (import.meta.env.DEV) {
    console.log(
      `${request.method} ${new URL(request.url).pathname} → ${status} (${durationMs}ms)`,
    );
  }
}
```
