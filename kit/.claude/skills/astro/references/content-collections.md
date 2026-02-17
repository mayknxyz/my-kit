# Content Collections (Astro 5)

Astro 5 introduced the **Content Layer API** with breaking changes from v4. This reference covers what changed.

For non-blog sites, prefer `src/data/` TypeScript modules instead (see [atomic-design.md](atomic-design.md)).

## Config File — New Location

```
Astro 5: src/content.config.ts    ← CORRECT
Astro 4: src/content/config.ts    ← LEGACY, do not use
```

## Loaders — Now Required

Astro 5 requires explicit loaders. The old `type: 'content'` / `type: 'data'` syntax is removed.

```typescript
// src/content.config.ts
import { defineCollection, z } from 'astro:content';
import { glob, file } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.coerce.date(),       // NOT z.date()
    tags: z.array(z.string()),
    draft: z.boolean().default(false),
  }),
});

const team = defineCollection({
  loader: file('src/data/team.json'),   // single JSON/YAML file
  schema: z.object({
    name: z.string(),
    role: z.string(),
  }),
});

export const collections = { blog, team };
```

### Built-in Loaders

- **`glob()`** — directories of Markdown/MDX/JSON/YAML files
- **`file()`** — single data file (JSON array, YAML)
- **Async function** — custom loader for remote/API data

## Schema Patterns

```typescript
// Date fields — ALWAYS use coerce
publishDate: z.coerce.date(),           // parses date strings correctly

// Images — use the helper for optimization
import { image } from 'astro:content';
cover: image(),                         // validates and optimizes

// Cross-collection references
relatedPosts: z.array(reference('blog')),

// Optional with defaults
draft: z.boolean().default(false),
```

## Querying — Same API, New `render()`

```typescript
import { getCollection, getEntry, render } from 'astro:content';

// Get all, with filter
const posts = await getCollection('blog', ({ data }) => !data.draft);

// Get one by ID
const post = await getEntry('blog', 'my-post');

// Render — NOW a standalone function (was method on entry in v4)
const { Content, headings } = await render(post);
```

## Dynamic Routes with Collections

```astro
---
// src/pages/blog/[slug].astro
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map((post) => ({
    params: { slug: post.id },
    props: { post },
  }));
}

const { post } = Astro.props;
const { Content } = await render(post);
---
<Content />
```

## Key Changes from v4

| v4 | v5 |
|----|-----|
| `src/content/config.ts` | `src/content.config.ts` |
| `type: 'content'` | `loader: glob({...})` |
| `type: 'data'` | `loader: file('...')` |
| `entry.render()` | `render(entry)` (standalone import) |
| `z.date()` | `z.coerce.date()` |
| `import { z } from 'astro:content'` | same (still works) |
| `import { z } from 'astro/zod'` | also valid |

Docs: <https://docs.astro.build/en/guides/content-collections/>
