# Coding Conventions — SvelteKit + Svelte 5

## Component Architecture (Svelte 5 Runes)

### Basic Component with `$props`

```svelte
<!-- src/lib/components/ui/Button.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte'

  interface Props {
    variant?: 'primary' | 'secondary' | 'ghost'
    size?: 'sm' | 'md' | 'lg'
    disabled?: boolean
    onclick?: () => void
    children: Snippet
  }

  let {
    variant = 'primary',
    size = 'md',
    disabled = false,
    onclick,
    children
  }: Props = $props()

  const classes = $derived(() => {
    const base = 'rounded-md font-medium transition-colors'
    const variants = {
      primary: 'bg-blue-600 text-white hover:bg-blue-700',
      secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
      ghost: 'bg-transparent hover:bg-gray-100'
    }
    const sizes = {
      sm: 'px-3 py-1.5 text-sm',
      md: 'px-4 py-2 text-base',
      lg: 'px-6 py-3 text-lg'
    }
    return `${base} ${variants[variant]} ${sizes[size]} ${disabled ? 'opacity-50 cursor-not-allowed' : ''}`
  })
</script>

<button
  class={classes}
  {disabled}
  {onclick}
>
  {@render children()}
</button>
```

### Complex Derived State with `$derived.by()`

```svelte
<script lang="ts">
  import type { User } from '$lib/types'

  let users = $state<User[]>([])
  let searchQuery = $state('')
  let roleFilter = $state<'all' | 'admin' | 'user'>('all')

  // Use $derived.by() for complex computation
  const filteredUsers = $derived.by(() => {
    let result = users

    if (searchQuery) {
      result = result.filter(u =>
        u.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        u.email.toLowerCase().includes(searchQuery.toLowerCase())
      )
    }

    if (roleFilter !== 'all') {
      result = result.filter(u => u.role === roleFilter)
    }

    return result.sort((a, b) => a.name.localeCompare(b.name))
  })
</script>

<input bind:value={searchQuery} placeholder="Search users..." />
<select bind:value={roleFilter}>
  <option value="all">All Roles</option>
  <option value="admin">Admins</option>
  <option value="user">Users</option>
</select>

{#each filteredUsers as user}
  <div>{user.name} - {user.role}</div>
{/each}
```

### Feature-Based Component

```svelte
<!-- src/lib/components/auth/LoginForm.svelte -->
<script lang="ts">
  import { enhance } from '$app/forms'
  import { goto } from '$app/navigation'
  import Button from '$lib/components/ui/Button.svelte'
  import Input from '$lib/components/ui/Input.svelte'
  import type { ActionData } from './$types'

  interface Props {
    form?: ActionData
  }

  let { form }: Props = $props()

  let isSubmitting = $state(false)

  $effect(() => {
    if (form?.success) {
      goto('/dashboard')
    }
  })
</script>

<form
  method="post"
  use:enhance={() => {
    isSubmitting = true
    return async ({ update }) => {
      await update()
      isSubmitting = false
    }
  }}
>
  <Input
    name="email"
    type="email"
    label="Email"
    error={form?.errors?.email}
    required
  />

  <Input
    name="password"
    type="password"
    label="Password"
    error={form?.errors?.password}
    required
  />

  <Button type="submit" disabled={isSubmitting}>
    {#snippet children()}
      {isSubmitting ? 'Logging in...' : 'Log in'}
    {/snippet}
  </Button>
</form>
```

## Component Structure Pattern

Every Svelte component follows this order:

```svelte
<!-- 1. Script block -->
<script lang="ts">
  // a. Imports
  import type { Snippet } from 'svelte'

  // b. Props interface and destructuring
  interface Props {
    title: string
    children?: Snippet
  }

  let { title, children }: Props = $props()

  // c. Local state and derived values
  let count = $state(0)
  let doubled = $derived(count * 2)

  // d. Effects
  $effect(() => {
    console.log('Count changed:', count)
  })

  // e. Functions
  function increment() {
    count++
  }
</script>

<!-- 2. Markup -->
<h1>{title}</h1>
<p>Count: {count} (Doubled: {doubled})</p>
<button onclick={increment}>Increment</button>
{#if children}
  {@render children()}
{/if}

<!-- 3. Scoped styles -->
<style>
  h1 { font-size: 2rem; }
</style>
```

## File Naming

- **Components**: PascalCase (`Button.svelte`, `UserProfile.svelte`)
- **Routes**: lowercase with directories (`users/[id]/+page.svelte`)
- **Utilities**: camelCase (`formatDate.ts`, `fetchApi.ts`)
- **Types**: camelCase or PascalCase (`types.ts`, `User.ts`)
- **Stores**: camelCase (`user.ts`, `cart.svelte.ts`)
- **Schemas**: camelCase (`user.ts`, `loginForm.ts`)

## State Management (Hybrid Approach)

### Local State (Runes)

```svelte
<script lang="ts">
  // Simple reactive state
  let count = $state(0)

  // Derived state
  let doubled = $derived(count * 2)

  // State with object (remains reactive)
  let user = $state({
    name: 'John',
    email: 'john@example.com'
  })

  // Effect for side effects
  $effect(() => {
    console.log('Count changed:', count)

    // Cleanup function
    return () => {
      console.log('Cleanup')
    }
  })

  function increment() {
    count++
  }

  function updateUser() {
    // Mutation works with $state
    user.name = 'Jane'
  }
</script>
```

### Global State (Stores)

```typescript
// src/lib/stores/user.ts
import { writable, derived } from 'svelte/store'
import type { User } from '$lib/types'

export const user = writable<User | null>(null)

export const isAuthenticated = derived(user, $u => $u !== null)

export const isAdmin = derived(user, $u => $u?.role === 'admin')

export const userActions = {
  login: (userData: User) => user.set(userData),
  logout: () => user.set(null),
  update: (updates: Partial<User>) => {
    user.update($u => $u ? { ...$u, ...updates } : null)
  }
}
```

### Context API (Scoped State)

```svelte
<!-- src/lib/components/auth/AuthProvider.svelte -->
<script lang="ts" module>
  import { getContext, setContext } from 'svelte'

  const AUTH_KEY = Symbol('auth')

  export function getAuthContext() {
    return getContext<ReturnType<typeof createAuthContext>>(AUTH_KEY)
  }
</script>

<script lang="ts">
  import type { Snippet } from 'svelte'

  interface Props {
    children: Snippet
  }

  let { children }: Props = $props()

  function createAuthContext() {
    let isAuthenticated = $state(false)
    let user = $state<{ id: string; name: string } | null>(null)

    return {
      get isAuthenticated() { return isAuthenticated },
      get user() { return user },
      login: (userData: { id: string; name: string }) => {
        isAuthenticated = true
        user = userData
      },
      logout: () => {
        isAuthenticated = false
        user = null
      }
    }
  }

  setContext(AUTH_KEY, createAuthContext())
</script>

{@render children()}
```

## Data Fetching (SvelteKit)

### Server-Side Data Loading

```typescript
// src/routes/users/[id]/+page.server.ts
import type { PageServerLoad } from './$types'
import { error } from '@sveltejs/kit'

export const load: PageServerLoad = async ({ params }) => {
  const result = await getUser(params.id)

  if (!result.success) {
    throw error(404, 'User not found')
  }

  return {
    user: result.data
  }
}
```

### Using Server Data in Component

```svelte
<!-- src/routes/users/[id]/+page.svelte -->
<script lang="ts">
  import type { PageData } from './$types'

  interface Props {
    data: PageData
  }

  let { data }: Props = $props()
</script>

<h1>{data.user.name}</h1>
<p>{data.user.email}</p>
```

## Forms & Validation

### Zod Schema

```typescript
// src/lib/schemas/user.ts
import { z } from 'zod'

export const userSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  age: z.number().int().positive().optional(),
})

export type UserInput = z.infer<typeof userSchema>
```

### Server-Side Form Actions

```typescript
// src/routes/signup/+page.server.ts
import type { Actions } from './$types'
import { fail } from '@sveltejs/kit'
import { userSchema } from '$lib/schemas/user'

export const actions: Actions = {
  default: async ({ request }) => {
    const formData = await request.formData()
    const data = {
      name: formData.get('name'),
      email: formData.get('email'),
      age: formData.get('age') ? Number(formData.get('age')) : undefined,
    }

    const result = userSchema.safeParse(data)

    if (!result.success) {
      return fail(400, {
        errors: result.error.flatten().fieldErrors,
        data,
      })
    }

    // Process the validated data
    // await createUser(result.data)

    return { success: true }
  }
}
```

### Progressive Enhancement Form

```svelte
<!-- src/routes/signup/+page.svelte -->
<script lang="ts">
  import { enhance } from '$app/forms'
  import type { ActionData } from './$types'

  interface Props {
    form?: ActionData
  }

  let { form }: Props = $props()
  let isSubmitting = $state(false)
</script>

<form
  method="post"
  use:enhance={() => {
    isSubmitting = true
    return async ({ update }) => {
      await update()
      isSubmitting = false
    }
  }}
>
  {#if form?.success}
    <p class="text-green-600">Success! Account created.</p>
  {/if}

  <label for="name">Name</label>
  <input type="text" name="name" id="name" value={form?.data?.name ?? ''} required />
  {#if form?.errors?.name}
    <p class="text-red-600">{form.errors.name[0]}</p>
  {/if}

  <label for="email">Email</label>
  <input type="email" name="email" id="email" value={form?.data?.email ?? ''} required />
  {#if form?.errors?.email}
    <p class="text-red-600">{form.errors.email[0]}</p>
  {/if}

  <button type="submit" disabled={isSubmitting}>
    {isSubmitting ? 'Submitting...' : 'Sign Up'}
  </button>
</form>
```

## Styling

### Tailwind + cn() Helper

```typescript
// src/lib/utils/cn.ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### Component Variants with CVA

```svelte
<script lang="ts">
  import { cva, type VariantProps } from 'class-variance-authority'
  import type { Snippet } from 'svelte'

  const buttonVariants = cva(
    'inline-flex items-center justify-center rounded-md font-medium transition-colors',
    {
      variants: {
        variant: {
          default: 'bg-primary text-primary-foreground hover:bg-primary/90',
          secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
          ghost: 'hover:bg-accent hover:text-accent-foreground',
        },
        size: {
          sm: 'h-9 px-3 text-sm',
          md: 'h-10 px-4 py-2',
          lg: 'h-11 px-8 text-lg',
        },
      },
      defaultVariants: {
        variant: 'default',
        size: 'md',
      },
    }
  )

  type ButtonVariants = VariantProps<typeof buttonVariants>

  interface Props extends ButtonVariants {
    class?: string
    children: Snippet
  }

  let { variant, size, class: className, children }: Props = $props()
</script>

<button class={buttonVariants({ variant, size, className })}>
  {@render children()}
</button>
```

## TypeScript Standards

- Extend SvelteKit's tsconfig: `"extends": "./.svelte-kit/tsconfig.json"`
- Enable strict mode with `noUncheckedIndexedAccess`, `noImplicitReturns`
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

## Hooks

### Server Hooks

```typescript
// src/hooks.server.ts
import { sequence } from '@sveltejs/kit/hooks'
import type { Handle } from '@sveltejs/kit'

const securityHeaders: Handle = async ({ event, resolve }) => {
  const response = await resolve(event)
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  return response
}

const authHook: Handle = async ({ event, resolve }) => {
  const session = event.cookies.get('session')
  if (session) {
    event.locals.user = await getUserFromSession(session)
  }
  return resolve(event)
}

export const handle = sequence(authHook, securityHeaders)
```

### Client Hooks

```typescript
// src/hooks.client.ts
import type { HandleClientError } from '@sveltejs/kit'

export const handleError: HandleClientError = ({ error, event }) => {
  console.error('Client error:', error, 'at', event.url.pathname)
  return {
    message: 'An unexpected error occurred. Please try again.'
  }
}
```

## Environment Variables

```bash
# Server-only (NEVER prefix with PUBLIC_)
DATABASE_URL=postgresql://localhost:5432/mydb
SECRET_KEY=your-secret-key-here

# Client-accessible (MUST prefix with PUBLIC_)
PUBLIC_API_URL=https://api.example.com
PUBLIC_APP_NAME="My App"
```

```typescript
// src/lib/server/env.ts
import { z } from 'zod'

const serverEnvSchema = z.object({
  DATABASE_URL: z.string().url(),
  SECRET_KEY: z.string().min(32),
})

const publicEnvSchema = z.object({
  PUBLIC_API_URL: z.string().url(),
  PUBLIC_APP_NAME: z.string(),
})

export const serverEnv = serverEnvSchema.parse(process.env)
export const publicEnv = publicEnvSchema.parse({
  PUBLIC_API_URL: import.meta.env.PUBLIC_API_URL,
  PUBLIC_APP_NAME: import.meta.env.PUBLIC_APP_NAME,
})
```

## Performance

- Default to SSR — use `ssr: false` only when strictly necessary
- Progressive enhancement with `use:enhance` for forms
- Use `$derived` instead of `$derived.by()` for simple expressions
- Code-split with dynamic imports for heavy components
- Use `enhanced:img` for automatic image optimization
- Core Web Vitals targets: LCP < 2.5s, FID < 100ms, CLS < 0.1

## Accessibility (WCAG 2.1 AA)

- Semantic HTML in all components
- All images must have descriptive `alt` text
- Interactive elements must be keyboard accessible
- Minimum 4.5:1 contrast ratio
- Use ARIA attributes only when native semantics are insufficient
- Respect `prefers-reduced-motion` media query

## Testing Strategy

- **Vitest**: Unit tests for utility functions, schemas, and business logic
- **Playwright**: E2E tests for critical user flows
- **Svelte check**: Type checking (`npm run check`)
- **Lighthouse**: Performance, accessibility, SEO audits
- **Build validation**: `npm run build` must succeed without errors

## Patterns to Avoid

| Avoid | Prefer |
|-------|--------|
| Class-based patterns | Plain functions and `$state` runes |
| Heavy state management (Redux/MobX) | Svelte stores + runes |
| CSS-in-JS (styled-components) | Tailwind or scoped styles |
| `$derived.by()` for simple cases | `$derived(expr)` |
| `any` type | `unknown` + Zod validation |
| TODO comments in code | Create GitHub issues instead |
| Testing before implementation | Write tests alongside code |
