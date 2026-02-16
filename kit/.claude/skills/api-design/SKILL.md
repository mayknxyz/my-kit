---
name: api-design
description: >
  REST API design — resource naming, error handling, validation, pagination, rate limiting.
  Use when designing API endpoints, error responses, input validation, or pagination.
  Triggers: API, REST, endpoint, HTTP methods, status codes, error response, pagination,
  rate limiting, input validation, Zod validation.
---

# API Design

Senior API engineer. REST conventions. Zod validation at boundaries. See `zod` skill for schema patterns, `cloudflare` skill for Workers/Pages API routes, `security` skill for security headers.

## REST Conventions

| Method | Action | Status | Example |
|---|---|---|---|
| `GET` | Read resource(s) | 200 | `GET /api/posts` |
| `POST` | Create resource | 201 | `POST /api/posts` |
| `PUT` | Replace resource | 200 | `PUT /api/posts/123` |
| `PATCH` | Partial update | 200 | `PATCH /api/posts/123` |
| `DELETE` | Remove resource | 204 | `DELETE /api/posts/123` |

### Resource Naming

- Plural nouns: `/api/posts`, `/api/users`
- Nested resources: `/api/posts/123/comments`
- Kebab-case for multi-word: `/api/blog-posts`
- No verbs in URLs: `/api/posts` not `/api/getPosts`

## Error Response Format

```ts
interface ApiError {
  error: string;       // Human-readable message
  code: string;        // Machine-readable code (VALIDATION_ERROR, NOT_FOUND, etc.)
  details?: object;    // Validation errors, field-level details
}

// Example
{
  "error": "Validation failed",
  "code": "VALIDATION_ERROR",
  "details": { "email": "Invalid email format" }
}
```

### Status Code Guide

| Code | When |
|---|---|
| 200 | Success (with body) |
| 201 | Created (POST success) |
| 204 | No content (DELETE success) |
| 400 | Validation error, bad request |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate) |
| 429 | Rate limited |
| 500 | Server error |

## Input Validation with Zod

```
Request → Parse body → Zod validate + sanitize → Process → Respond
```

Zod `.transform()` handles sanitization inline — no separate step needed. For full schema patterns, see `zod` skill (Form Input Sanitization section).

```ts
import { z } from "zod";

const ContactSchema = z.object({
  name: z.string().min(1).max(100).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")),
  email: z.string().email().max(255).toLowerCase(),
  message: z.string().min(10).max(5000).trim()
    .transform((s) => s.replace(/<[^>]*>/g, "")),
});

export async function POST({ request }: APIContext) {
  const body = await request.json();
  const result = ContactSchema.safeParse(body);

  if (!result.success) {
    return Response.json(
      { error: "Validation failed", code: "VALIDATION_ERROR", details: result.error.flatten().fieldErrors },
      { status: 400 }
    );
  }

  // result.data is typed, validated, AND sanitized
}
```

**Sanitization notes:**
- Plain-text fields (forms): strip HTML tags via Zod `.transform()` — works on Workers edge
- HTML content (CMS/blog): sanitize with `sanitize-html` at build time before storage (see `security` skill)
- Always sanitize before forwarding to external services (webhooks, CRMs, email templates)

## Pagination

### Cursor-Based (Preferred)

```ts
// Response
{
  "data": [...],
  "cursor": "abc123",      // null if no more pages
  "hasMore": true
}

// Next request: GET /api/posts?cursor=abc123&limit=20
```

### Offset-Based (Simpler)

```ts
// GET /api/posts?page=2&limit=20
{
  "data": [...],
  "page": 2,
  "totalPages": 10,
  "total": 200
}
```

## Rate Limiting

- Use IP-based + token bucket for public APIs
- Return `429` with `Retry-After` header
- Cloudflare Rate Limiting rules for edge enforcement

## References

| Topic | File | Load When |
|-------|------|-----------|
| API route patterns | [patterns.md](references/patterns.md) | Route boilerplate, error helper, cursor pagination, Turnstile verification |

## MUST DO

- Validate all input with Zod at API boundary using `safeParse()`
- Return consistent error format `{ error, code, details? }`
- Use correct HTTP methods and status codes
- Use cursor-based pagination for large datasets
- Rate limit all public endpoints
- Return `Content-Type: application/json` for JSON responses

## MUST NOT

- Use `GET` for mutations (create, update, delete)
- Return `200` for errors — use proper 4xx/5xx codes
- Skip input validation — validate every field server-side
- Expose internal error details (stack traces) to clients
- Use sequential IDs if they expose business metrics — use UUIDs
- Accept unbounded input (always set `max` limits on strings, arrays)
- Forward unsanitized user input to external services (webhooks, CRMs, email templates)
