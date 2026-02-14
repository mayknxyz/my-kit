# SEO Patterns

Reusable JSON-LD templates, Astro SEO components, and technical SEO configurations.

## JSON-LD Templates

### Organization

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Company Name",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "description": "What the company does",
  "sameAs": [
    "https://twitter.com/handle",
    "https://linkedin.com/company/handle",
    "https://github.com/handle"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "email": "hello@example.com",
    "contactType": "customer service"
  }
}
```

### Local Business

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Business Name",
  "url": "https://example.com",
  "telephone": "+1-555-0100",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "City",
    "addressRegion": "ST",
    "postalCode": "12345",
    "addressCountry": "US"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      "opens": "09:00",
      "closes": "17:00"
    }
  ]
}
```

### Service

```json
{
  "@context": "https://schema.org",
  "@type": "Service",
  "name": "Service Name",
  "description": "What the service provides",
  "provider": {
    "@type": "Organization",
    "name": "Company Name"
  },
  "areaServed": {
    "@type": "City",
    "name": "City Name"
  },
  "serviceType": "Category"
}
```

### FAQ Page

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is your return policy?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "We offer 30-day returns on all items."
      }
    },
    {
      "@type": "Question",
      "name": "How long does shipping take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Standard shipping takes 3-5 business days."
      }
    }
  ]
}
```

### Breadcrumbs

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://example.com"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Services",
      "item": "https://example.com/services"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "Web Design"
    }
  ]
}
```

### Blog Post

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Post Title",
  "description": "Post excerpt",
  "image": "https://example.com/images/post.jpg",
  "datePublished": "2026-01-15",
  "dateModified": "2026-01-20",
  "author": {
    "@type": "Person",
    "name": "Author Name",
    "url": "https://example.com/about"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Site Name",
    "logo": {
      "@type": "ImageObject",
      "url": "https://example.com/logo.png"
    }
  }
}
```

## Astro SEO Component

Reusable `<head>` component for Astro pages:

```astro
---
// src/components/atoms/SEO.astro
interface Props {
  title: string;
  description: string;
  canonical?: string;
  ogImage?: string;
  ogType?: "website" | "article";
  noindex?: boolean;
}

const {
  title,
  description,
  canonical = Astro.url.href,
  ogImage = "/og-default.png",
  ogType = "website",
  noindex = false,
} = Astro.props;

const siteName = "Site Name";
const fullTitle = `${title} — ${siteName}`;
const ogImageUrl = new URL(ogImage, Astro.site).href;
---

<title>{fullTitle}</title>
<meta name="description" content={description} />
<link rel="canonical" href={canonical} />
{noindex && <meta name="robots" content="noindex, nofollow" />}

<meta property="og:type" content={ogType} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={ogImageUrl} />
<meta property="og:url" content={canonical} />
<meta property="og:site_name" content={siteName} />

<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content={title} />
<meta name="twitter:description" content={description} />
<meta name="twitter:image" content={ogImageUrl} />
```

## Sitemap Configuration

### Astro Built-in Sitemap

```ts
// astro.config.mjs
import sitemap from "@astrojs/sitemap";

export default defineConfig({
  site: "https://example.com",
  integrations: [
    sitemap({
      filter: (page) => !page.includes("/admin/"),
      changefreq: "weekly",
      priority: 0.7,
      lastmod: new Date(),
    }),
  ],
});
```

## robots.txt

```
# public/robots.txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/

Sitemap: https://example.com/sitemap-index.xml
```

## Validation Checklist

Per-page SEO review:

- [ ] Unique `<title>` (50-60 chars) with primary keyword
- [ ] Unique `<meta description>` (150-160 chars)
- [ ] Canonical URL set
- [ ] Open Graph tags (title, description, image, url)
- [ ] Twitter Card tags
- [ ] JSON-LD structured data (at minimum WebSite + Organization on homepage)
- [ ] All images have descriptive `alt` text
- [ ] Heading hierarchy is correct (h1 → h2 → h3)
- [ ] URLs are descriptive and kebab-case
- [ ] Internal links use descriptive anchor text (not "click here")
