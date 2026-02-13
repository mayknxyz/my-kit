---
name: seo
description: >
  SEO optimization with JSON-LD structured data, Open Graph, and technical SEO. Use when
  adding meta tags, structured data, sitemaps, canonical URLs, or optimizing for search.
  Triggers: SEO, meta tags, JSON-LD, structured data, Open Graph, Twitter Card, canonical,
  sitemap, robots.txt, schema.org, og:image, breadcrumbs.
---

# SEO

Senior SEO engineer. Structured data first. Technical SEO. See `performance` skill for Core Web Vitals, `a11y` skill for accessibility (also a ranking factor).

## JSON-LD Structured Data

Always include relevant schema.org types as JSON-LD in `<head>`:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Site Name",
  "url": "https://example.com",
  "description": "Site description"
}
</script>
```

### Common Types for Business Sites

| Type | Use For |
|---|---|
| `WebSite` | Every site — homepage, search action |
| `Organization` | Business info — name, logo, contact, socials |
| `LocalBusiness` | Physical location — address, hours, geo |
| `Service` | Service offerings — description, provider, area |
| `Article` / `BlogPosting` | Blog posts — author, date, headline |
| `FAQ` / `FAQPage` | FAQ sections — question/answer pairs |
| `BreadcrumbList` | Navigation breadcrumbs |
| `Product` | Products — price, availability, reviews |

### Nesting Pattern

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Company",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "sameAs": ["https://twitter.com/handle", "https://linkedin.com/company/handle"],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-555-0100",
    "contactType": "customer service"
  }
}
```

## Meta Tags Pattern

```html
<!-- Primary -->
<title>Page Title — Site Name</title>
<meta name="description" content="155-char max description with keywords" />
<link rel="canonical" href="https://example.com/page" />

<!-- Open Graph -->
<meta property="og:type" content="website" />
<meta property="og:title" content="Page Title" />
<meta property="og:description" content="Description for social sharing" />
<meta property="og:image" content="https://example.com/og-image.png" />
<meta property="og:url" content="https://example.com/page" />

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="Page Title" />
<meta name="twitter:description" content="Description" />
<meta name="twitter:image" content="https://example.com/og-image.png" />
```

## Technical SEO

- **Canonical URLs**: Every page needs one — prevents duplicate content
- **Sitemap**: Generate `sitemap-index.xml` with all public URLs
- **robots.txt**: Allow crawling, point to sitemap
- **OG images**: 1200x630px, under 1MB, unique per page when possible
- **Title format**: `Page Title — Site Name` (50-60 chars)
- **Description**: 150-160 chars, include primary keyword naturally

## CLI Tools

```bash
# Broken link checker — crawls entire site
linkinator https://example.com --recurse
linkinator https://example.com --recurse --format json

# SEO audit via Lighthouse
lighthouse https://example.com --only-categories=seo --output json
```

## MUST DO

- Add JSON-LD structured data to every page (at minimum `WebSite` + `Organization`)
- Set unique `<title>` and `<meta name="description">` per page
- Include Open Graph and Twitter Card meta tags
- Set canonical URL on every page
- Generate and submit XML sitemap
- Use descriptive, keyword-rich URLs (kebab-case)

## MUST NOT

- Skip structured data — it enables rich results in search
- Use duplicate title/description across pages
- Forget `og:image` — social shares without images get ignored
- Use JavaScript-only content for critical SEO pages (prefer SSG/SSR)
- Stuff keywords unnaturally — write for humans first
- Use `noindex` on pages you want indexed (check robots meta)
