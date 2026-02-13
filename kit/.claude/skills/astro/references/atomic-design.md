# Atomic Design + Data Layer

## Component Hierarchy

```
src/components/
├── atoms/        # Single-purpose, no component dependencies
├── molecules/    # Compose 2+ atoms into a functional unit
├── organisms/    # Full page sections, complex behavior
└── templates/    # Page-level wrappers, define layout structure
```

### Atoms
Smallest building blocks. No child component dependencies. Reusable everywhere.

Examples: `Button`, `Icon`, `Divider`, `TurnstileWidget`, `OptimizedImage`, `LoadingSpinner`, `StructuredData`, `ScrollToTop`, `HeroImage`

### Molecules
Combine multiple atoms into a functional unit with a single purpose.

Examples: `Card`, `CTASection`, `AudioPlayer`, `YouTubeEmbed`, `Pagination`, `PlatformIcons`, `FormThankYou`

### Organisms
Complete page sections. Compose atoms + molecules. May have internal state or scripts.

Examples: `Header`, `Footer`, `Hero`, `MusicShowcase`, `ContactForm`, `VideoShowcase`, `StreamingPlatforms`

### Templates
Page-level layout wrappers. Define shared HTML structure, meta tags, global scripts.

Examples: `BaseLayout`, `BaseTemplate`, `BlogPostLayout`

### Promotion Rules
- Atom → Molecule: when it composes other atoms or gains internal interaction logic
- Molecule → Organism: when it represents a complete page section, not a reusable widget
- Organism → Template: when it wraps an entire page and manages `<html>`, `<head>`, slots for page content

## Centralized Data Layer (`src/data/`)

For non-blog sites, centralize all content in TypeScript modules instead of content collections. Components receive data as props — never hardcode content.

```
src/data/
├── index.ts          # barrel exports
├── types.ts          # shared TypeScript interfaces
├── site.ts           # site name, URL, author, brand colors
├── navigation.ts     # nav links and menu structure
├── seo.ts            # default meta tags, structured data templates
├── images.ts         # image URLs / Cloudflare Images config
├── home/             # page-specific content
│   ├── index.ts
│   ├── about.ts
│   └── hero.ts
└── pages/
    ├── index.ts
    ├── about.ts
    └── contact.ts
```

### Conventions
- Export `readonly` typed objects with `interface` definitions
- Use barrel exports (`index.ts`) for clean imports
- Split by page when data is page-specific (`data/home/`, `data/pages/`)
- Keep shared data at root level (`site.ts`, `navigation.ts`)
- Use content collections only for blog/article sites that need Markdown/MDX rendering

## Component Conventions

```astro
---
// 1. Imports
import Button from '@components/atoms/Button.astro';

// 2. Props interface
interface Props {
  title: string;
  description?: string;
  variant?: 'default' | 'primary' | 'secondary';
}

// 3. Destructure with defaults
const { title, description, variant = 'default' } = Astro.props;
---

<!-- 4. Template -->
<section>
  <h2>{title}</h2>
  {description && <p>{description}</p>}
  <slot />
</section>

<!-- 5. Scoped styles -->
<style>
  section { /* scoped by default */ }
</style>
```
