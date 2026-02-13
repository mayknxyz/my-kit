# Coding Conventions — Astro

## Component Architecture (Atomic Design)

### Atoms (Basic Building Blocks)

```astro
---
// src/components/atoms/Button.astro
interface Props {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  type?: 'button' | 'submit' | 'reset'
  class?: string
}

const {
  variant = 'primary',
  size = 'md',
  disabled = false,
  type = 'button',
  class: className = ''
} = Astro.props
---

<button
  type={type}
  disabled={disabled}
  class:list={[
    'rounded-md font-medium transition-colors',
    variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
    variant === 'secondary' && 'bg-gray-200 text-gray-900 hover:bg-gray-300',
    variant === 'ghost' && 'bg-transparent hover:bg-gray-100',
    size === 'sm' && 'px-3 py-1.5 text-sm',
    size === 'md' && 'px-4 py-2 text-base',
    size === 'lg' && 'px-6 py-3 text-lg',
    disabled && 'opacity-50 cursor-not-allowed',
    className
  ]}
>
  <slot />
</button>
```

### Molecules (Component Groups)

```astro
---
// src/components/molecules/SearchBar.astro
import Button from '@components/atoms/Button.astro'

interface Props {
  placeholder?: string
  action?: string
}

const { placeholder = 'Search...', action = '/search' } = Astro.props
---

<form method="get" action={action} class="flex gap-2">
  <input
    type="search"
    name="q"
    placeholder={placeholder}
    class="flex-1 px-4 py-2 border rounded-md focus:outline-none focus:ring-2"
  />
  <Button type="submit" variant="primary">
    <span class="sr-only">Search</span>
  </Button>
</form>
```

### Organisms (Complex Components)

```astro
---
// src/components/organisms/Header.astro
import Navigation from '@components/molecules/Navigation.astro'
import Logo from '@components/atoms/Logo.astro'

interface Props {
  currentPath: string
}

const { currentPath } = Astro.props
---

<header class="sticky top-0 bg-white shadow-sm z-50">
  <div class="container mx-auto px-4 py-4 flex items-center justify-between">
    <Logo />
    <Navigation currentPath={currentPath} />
  </div>
</header>
```

## Component Structure Pattern

Every Astro component follows this order:

```astro
---
// 1. Imports
import BaseLayout from '../layouts/BaseLayout.astro'

// 2. Props interface
interface Props {
  title: string
  description?: string
}

// 3. Props destructuring and logic
const { title, description } = Astro.props
---

<!-- 4. Markup -->
<BaseLayout title={title}>
  <h1>{title}</h1>
  {description && <p>{description}</p>}
</BaseLayout>

<!-- 5. Scoped styles -->
<style>
  h1 { font-size: 2rem; }
</style>
```

## File Naming

- **Components**: PascalCase (`Button.astro`, `UserProfile.astro`)
- **Pages**: kebab-case (`about.astro`, `blog-post.astro`)
- **Utilities**: camelCase (`formatDate.ts`, `fetchApi.ts`)
- **Content**: kebab-case (`my-first-post.md`)
- **Layouts**: PascalCase (`BaseLayout.astro`, `BlogLayout.astro`)

## Content Collections

### Schema Definition

```typescript
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.coerce.date(),
    author: z.string(),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
    image: z.object({
      src: z.string(),
      alt: z.string(),
    }).optional(),
  }),
})

export const collections = { blog }
```

### Querying Collections

```astro
---
import { getCollection } from 'astro:content'

const posts = (await getCollection('blog', ({ data }) => {
  return !data.draft
})).sort((a, b) => b.data.publishDate.valueOf() - a.data.publishDate.valueOf())
---
```

### Rendering Entries

```astro
---
import { getCollection } from 'astro:content'
import type { GetStaticPaths } from 'astro'

export const getStaticPaths: GetStaticPaths = async () => {
  const entries = await getCollection('blog')
  return entries.map(entry => ({
    params: { slug: entry.slug },
    props: { entry },
  }))
}

const { entry } = Astro.props
const { Content } = await entry.render()
---

<article>
  <h1>{entry.data.title}</h1>
  <Content />
</article>
```

## Styling

### Scoped Styles

Styles in `<style>` tags are automatically scoped to the component.

### Global Styles

Place in `src/styles/global.css` and import in the base layout:

```astro
---
import '../styles/global.css'
---
```

### Design Tokens

```css
:root {
  --color-primary: #2563eb;
  --color-text: #1f2937;
  --color-bg: #ffffff;
  --font-sans: system-ui, -apple-system, sans-serif;
}
```

### Tailwind + class:list

```astro
---
interface Props {
  variant?: 'default' | 'outlined'
  class?: string
}

const { variant = 'default', class: className } = Astro.props

const variantStyles = {
  default: 'bg-white shadow-md',
  outlined: 'border-2 border-gray-300'
}
---

<div class:list={['rounded-lg p-4', variantStyles[variant], className]}>
  <slot />
</div>
```

## TypeScript Standards

- Enable strict mode via `"extends": "astro/tsconfigs/strict"`
- No `any` types — use `unknown` and narrow with type guards
- Define interfaces for all data structures
- Use Zod for runtime validation of external data
- Use `import type` for type-only imports

```typescript
// src/lib/types/index.ts
export type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E }
```

## Data Fetching

### Server-Side (in frontmatter)

```astro
---
import type { User } from '@lib/types'
import { getUser } from '@lib/api/users'

const { id } = Astro.params
if (!id) return Astro.redirect('/404')

const result = await getUser(id)
if (!result.success) return Astro.redirect('/error')

const user = result.data
---

<h1>{user.name}</h1>
```

## Forms & Validation

### Zod Schema

```typescript
// src/lib/schemas/user.ts
import { z } from 'zod'

export const userSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
})

export type UserInput = z.infer<typeof userSchema>
```

### Progressive Enhancement (POST handling)

```astro
---
import { userSchema } from '@lib/schemas/user'

let errors: Record<string, string[]> = {}
let success = false

if (Astro.request.method === 'POST') {
  const formData = await Astro.request.formData()
  const data = {
    name: formData.get('name'),
    email: formData.get('email'),
  }

  const result = userSchema.safeParse(data)
  if (result.success) {
    success = true
  } else {
    errors = result.error.flatten().fieldErrors
  }
}
---

<form method="post">
  {success && <p class="text-green-600">Success!</p>}

  <label for="name">Name</label>
  <input type="text" name="name" id="name" required />
  {errors.name && <p class="text-red-600">{errors.name[0]}</p>}

  <label for="email">Email</label>
  <input type="email" name="email" id="email" required />
  {errors.email && <p class="text-red-600">{errors.email[0]}</p>}

  <button type="submit">Submit</button>
</form>
```

### Astro Actions

```typescript
// src/actions/index.ts
import { defineAction } from 'astro:actions'
import { z } from 'zod'

export const server = {
  newsletter: defineAction({
    accept: 'form',
    input: z.object({
      email: z.string().email(),
      name: z.string().min(2),
    }),
    handler: async (input) => {
      await subscribeToNewsletter(input.email, input.name)
      return { success: true, message: 'Subscribed!' }
    },
  }),
}
```

## View Transitions

```astro
---
// src/layouts/BaseLayout.astro
import { ViewTransitions } from 'astro:transitions'
---

<html>
  <head>
    <ViewTransitions fallback="animate" />
  </head>
  <body><slot /></body>
</html>
```

Custom animations and persistent elements:

```astro
<div transition:animate={fade({ duration: '0.3s' })}>...</div>
<header transition:persist>...</header>
```

## Environment Variables

```bash
# Public (client-accessible)
PUBLIC_API_URL=https://api.example.com

# Private (server-only)
DATABASE_URL=postgresql://...
API_SECRET_KEY=secret123
```

```typescript
// src/lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  PUBLIC_API_URL: z.string().url(),
  DATABASE_URL: z.string().min(1),
})

export const env = envSchema.parse(import.meta.env)
```

## Middleware

```typescript
// src/middleware/index.ts
import { sequence } from 'astro:middleware'
import type { MiddlewareHandler } from 'astro'

const securityHeaders: MiddlewareHandler = async (context, next) => {
  const response = await next()
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  return response
}

const authMiddleware: MiddlewareHandler = async (context, next) => {
  const token = context.cookies.get('auth_token')?.value
  const publicRoutes = ['/', '/login', '/signup']
  if (publicRoutes.includes(context.url.pathname)) return next()
  if (!token) return context.redirect('/login')
  return next()
}

export const onRequest = sequence(securityHeaders, authMiddleware)
```

## Performance

- Ship zero JavaScript by default — only add `client:*` directives when needed
- Prefer `client:visible` or `client:idle` over `client:load` for non-critical components
- Use Astro's built-in `<Image />` for automatic image optimization
- Use content collections for type-safe markdown content
- Core Web Vitals targets: LCP < 2.5s, FID < 100ms, CLS < 0.1

## Accessibility (WCAG 2.1 AA)

- Semantic HTML in all components
- All images must have descriptive `alt` text
- Interactive elements must be keyboard accessible
- Minimum 4.5:1 contrast ratio
- Use ARIA attributes only when native semantics are insufficient
- Respect `prefers-reduced-motion` media query

## Testing Strategy

- **Vitest**: Unit tests for utility functions and business logic
- **Playwright**: E2E tests for critical user flows
- **Lighthouse**: Performance, accessibility, SEO audits
- **Build validation**: `npm run build` must succeed without errors

## Patterns to Avoid

| Avoid | Prefer |
|-------|--------|
| Class-based patterns | Plain functions and objects |
| Heavy state management (Redux) | Nano Stores if needed |
| CSS-in-JS (styled-components) | Tailwind or scoped styles |
| `client:load` on everything | No directive (static) by default |
| Hardcoded content in components | Content via slots and props |
| `any` type | `unknown` + Zod validation |
| JavaScript for simple UI interactions | CSS pseudo-classes and transitions |
