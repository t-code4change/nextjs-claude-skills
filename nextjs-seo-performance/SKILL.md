---
name: nextjs-seo-performance
description: >
  Flagship SEO + Performance skill for Next.js App Router. Use when implementing
  or auditing SEO (metadata, Open Graph, JSON-LD, sitemap, robots, canonical,
  hreflang), optimizing Core Web Vitals (LCP/INP/CLS), optimizing images/fonts/
  scripts/bundles, setting up Web Vitals monitoring, or diagnosing Google indexing
  problems. Also for dynamic OG images, AI crawler rules, and security headers.
argument-hint: "[page, component, or audit question]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Next.js SEO & Performance

> **Priority**: SEO correctness → Core Web Vitals → Bundle size → Runtime perf.
> A fast page that isn't indexed is worthless. An indexed page that's slow loses rankings.

---

## Quick SEO Audit

```bash
curl https://your-site.com/robots.txt
curl https://your-site.com/sitemap.xml
curl -s https://your-site.com | grep -E '<title|<meta name="description|og:image|og:title'
curl -s https://your-site.com | grep 'application/ld+json'
# Core Web Vitals (field data): https://pagespeed.web.dev
# Lighthouse is lab-only — CANNOT measure INP (most failed metric)
```

---

## 1. Metadata API

### Root Layout

```typescript
// app/layout.tsx
import type { Metadata, Viewport } from 'next';

// viewport MUST be a separate export — not inside metadata object
export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#ffffff' },
    { media: '(prefers-color-scheme: dark)', color: '#0a0a0a' },
  ],
};

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? 'https://your-site.com'),
  title: {
    default: 'Site Name — Main Keyword',
    template: '%s | Site Name',
  },
  description: 'Compelling 150–160 char description with primary keyword.',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    siteName: 'Site Name',
    images: [{ url: '/og-image.png', width: 1200, height: 630, alt: 'Site preview' }],
  },
  twitter: { card: 'summary_large_image', images: ['/og-image.png'] },
  alternates: { canonical: '/' },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true, 'max-image-preview': 'large' },
  },
};
```

### Dynamic Metadata (per page)

```typescript
// app/products/[slug]/page.tsx
type Props = { params: Promise<{ slug: string }> };  // Promise in Next.js 15+

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const product = await getProduct(slug);
  if (!product) return { title: 'Not Found' };
  return {
    title: product.name,               // template in layout applies automatically
    description: product.description.slice(0, 160),
    openGraph: {
      title: product.name,
      images: [{ url: product.image, width: 1200, height: 630, alt: product.name }],
    },
    alternates: { canonical: `/products/${slug}` },
  };
}
```

### Metadata Anti-patterns

```typescript
// ❌ viewport inside metadata
export const metadata: Metadata = { viewport: 'width=device-width' };

// ❌ missing metadataBase (relative OG URLs break)
export const metadata: Metadata = { openGraph: { images: ['/og.png'] } };

// ❌ next-seo package in App Router — use built-in Metadata API only

// ❌ mixing metadata object + generateMetadata in same route segment
```

---

## 2. Open Graph Images

### Static file convention (recommended default)

```
app/
├── opengraph-image.png      ← 1200×630, auto-emits og:image tags
├── opengraph-image.alt.txt  ← alt text
└── blog/
    └── opengraph-image.png  ← overrides root for /blog/*
```

### Dynamic OG with ImageResponse

```tsx
// app/blog/[slug]/opengraph-image.tsx
import { ImageResponse } from 'next/og';

export const alt = 'Blog post preview';
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';

export default async function Image({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const post = await getPost(slug);
  return new ImageResponse(
    (
      <div style={{ display: 'flex', flexDirection: 'column', width: '100%', height: '100%',
        backgroundColor: '#0f172a', padding: 60 }}>
        <div style={{ color: '#94a3b8', fontSize: 24 }}>{post.category}</div>
        <div style={{ color: '#f8fafc', fontSize: 56, fontWeight: 700 }}>{post.title}</div>
      </div>
    ),
    { ...size },
  );
}
// CONSTRAINT: flexbox only — display:grid is NOT supported (Satori limitation)
```

---

## 3. Structured Data / JSON-LD

```tsx
// components/json-ld.tsx
export function JsonLd({ data }: { data: Record<string, unknown> }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
```

### Organization (root layout)

```tsx
<JsonLd data={{
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Company Name',
  url: 'https://your-site.com',
  logo: 'https://your-site.com/logo.png',
  sameAs: ['https://twitter.com/handle', 'https://linkedin.com/company/name'],
}} />
```

### Product

```tsx
<JsonLd data={{
  '@context': 'https://schema.org',
  '@type': 'Product',
  name: product.name,
  description: product.description,
  image: product.images,
  brand: { '@type': 'Brand', name: product.brand },
  offers: {
    '@type': 'Offer',
    price: product.price,
    priceCurrency: 'USD',
    availability: product.inStock
      ? 'https://schema.org/InStock'
      : 'https://schema.org/OutOfStock',
  },
  aggregateRating: product.rating ? {
    '@type': 'AggregateRating',
    ratingValue: product.rating.average,
    reviewCount: product.rating.count,
  } : undefined,
}} />
```

### Article

```tsx
<JsonLd data={{
  '@context': 'https://schema.org',
  '@type': 'Article',
  headline: post.title,
  image: post.coverImage,
  datePublished: post.publishedAt,
  dateModified: post.updatedAt,
  author: { '@type': 'Person', name: post.author.name },
  publisher: {
    '@type': 'Organization',
    name: 'Site Name',
    logo: { '@type': 'ImageObject', url: 'https://your-site.com/logo.png' },
  },
}} />
```

### FAQ

```tsx
<JsonLd data={{
  '@context': 'https://schema.org',
  '@type': 'FAQPage',
  mainEntity: faqs.map(faq => ({
    '@type': 'Question',
    name: faq.question,
    acceptedAnswer: { '@type': 'Answer', text: faq.answer },
  })),
}} />
```

### BreadcrumbList

```tsx
<JsonLd data={{
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: items.map((item, i) => ({
    '@type': 'ListItem',
    position: i + 1,
    name: item.name,
    item: item.url,
  })),
}} />
```

---

## 4. Technical SEO

### Sitemap

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const BASE_URL = 'https://your-site.com';
  const posts = await getPosts();
  return [
    { url: BASE_URL, lastModified: new Date(), changeFrequency: 'weekly', priority: 1 },
    { url: `${BASE_URL}/about`, lastModified: new Date(), changeFrequency: 'monthly', priority: 0.8 },
    ...posts.map(post => ({
      url: `${BASE_URL}/blog/${post.slug}`,
      lastModified: post.updatedAt,
      changeFrequency: 'weekly' as const,
      priority: 0.6,
    })),
  ];
}
```

### robots.txt

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/admin/'],
        // NEVER disallow /_next/ — crawlers need CSS/JS to render pages
      },
      { userAgent: 'GPTBot', disallow: '/' },   // block OpenAI training
      { userAgent: 'CCBot', disallow: '/' },    // block Common Crawl training
      // OAI-SearchBot, PerplexityBot, ClaudeBot → leave ALLOWED (citation bots)
    ],
    sitemap: 'https://your-site.com/sitemap.xml',
  };
}
```

### Canonical + hreflang

```typescript
// Canonical (prevent duplicate content from query params)
export async function generateMetadata({ params }): Promise<Metadata> {
  const { slug } = await params;
  return { alternates: { canonical: `/products/${slug}` } };
}

// hreflang (i18n SEO)
export async function generateMetadata({ params }): Promise<Metadata> {
  const { locale } = await params;
  return {
    alternates: {
      canonical: `/${locale}`,
      languages: {
        'en-US': '/en',
        'vi-VN': '/vi',
        'x-default': '/en',  // fallback for unmatched locales
      },
    },
  };
}
```

---

## 5. Core Web Vitals

> Google uses **field data** (75th percentile, 28-day window). Lighthouse is lab-only.
> Use PageSpeed Insights + Search Console CWV report for real signal.
> **INP replaced FID in 2024** — most commonly failed metric.

| Metric | Good | Poor |
|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | > 4.0s |
| INP (Interaction to Next Paint) | < 200ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.25 |

### LCP Fixes

```tsx
// ✅ priority on LCP image
<Image src="/hero.jpg" alt="Hero" width={1280} height={720}
  priority quality={85} sizes="100vw" placeholder="blur" blurDataURL={hero.blur} />

// ✅ preconnect to image CDN
<link rel="preconnect" href="https://your-cdn.com" />

// ✅ next/font eliminates font-related LCP delay
const inter = Inter({ subsets: ['latin'], display: 'swap' });
```

| LCP Cause | Fix |
|---|---|
| LCP image without priority | Add `priority` to hero `<Image>` |
| Slow TTFB | `'use cache'` + CDN edge delivery |
| Render-blocking resources | `next/font`, `strategy="afterInteractive"` |
| Font flash causing repaint | `next/font` with `display: 'swap'` |

### INP Fixes

```tsx
// useTransition for non-urgent updates
const [isPending, startTransition] = useTransition();
<input onChange={(e) => {
  setQuery(e.target.value);                   // urgent
  startTransition(() => setSearchQuery(e.target.value));  // non-urgent
}} />

// useDeferredValue for expensive renders
const deferredQuery = useDeferredValue(query);
const filtered = expensiveFilter(deferredQuery);  // won't block input
```

| INP Cause | Fix |
|---|---|
| Heavy event handler | `startTransition` or `requestIdleCallback` |
| Large component re-renders | `useDeferredValue`, `React.memo` |
| Third-party scripts on main thread | `strategy="lazyOnload"` |

### CLS Fixes

```tsx
// ✅ explicit image dimensions prevent layout shift
<Image src="/product.jpg" alt="Product" width={600} height={400} />

// ✅ fill with sized container
<div className="relative aspect-[3/2] w-full">
  <Image src="/banner.jpg" alt="Banner" fill className="object-cover" />
</div>

// ✅ reserve space for async content
<div className="min-h-[200px]">
  <Suspense fallback={<Skeleton className="h-[200px]" />}>
    <DynamicContent />
  </Suspense>
</div>
```

| CLS Cause | Fix |
|---|---|
| Images without dimensions | Set `width`/`height` or `fill` with container |
| Font FOUT/FOIT | Use `next/font` |
| Dynamic content above fold | Reserve space with `min-height` / Skeleton |
| CSS animations on layout props | Animate `transform` instead |

---

## 6. Image Optimization

```tsx
import Image from 'next/image';

// Fixed size
<Image
  src="/photo.jpg"
  alt="Descriptive alt text"   // REQUIRED — never empty for content images
  width={800} height={600}
  quality={85}                 // default 75 — use 85 for hero images
  priority                     // ONLY for LCP image — don't add to all images
  placeholder="blur"
  blurDataURL={blurDataUrl}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>

// Fill container
<div className="relative w-full aspect-video">
  <Image src="/banner.jpg" alt="Banner" fill sizes="100vw"
    className="object-cover" priority />
</div>
```

### `sizes` attribute — Critical

```tsx
<Image sizes="100vw" />                                    // full-width
<Image sizes="(max-width: 768px) 100vw, 50vw" />          // 2-col grid
<Image sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw" />  // 3-col
<Image sizes="(max-width: 768px) 100vw, 280px" />          // fixed sidebar
```

### next.config.ts

```typescript
const nextConfig = {
  images: {
    remotePatterns: [{ protocol: 'https', hostname: 'cdn.example.com' }],
    formats: ['image/avif', 'image/webp'],
  },
};
```

### Anti-patterns

```tsx
// ❌ native <img> tag — no optimization
<img src="/hero.jpg" />

// ❌ priority on every image — wastes bandwidth
// Add priority ONLY to LCP image (usually one per page)

// ❌ empty alt on content images — bad SEO and accessibility
<Image alt="" src="..." />   // only OK for purely decorative images

// ❌ fill without positioned container
<Image fill ... />   // needs: relative/absolute parent with explicit size
```

---

## 7. Font Optimization

```typescript
// app/layout.tsx
import { Inter } from 'next/font/google';
import localFont from 'next/font/local';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',         // shows fallback immediately — prevents CLS
  variable: '--font-inter',
  preload: true,
});

// Local font (best — served from your domain, zero external request)
const customFont = localFont({
  src: [
    { path: '../fonts/custom-400.woff2', weight: '400', style: 'normal' },
    { path: '../fonts/custom-700.woff2', weight: '700', style: 'normal' },
  ],
  variable: '--font-custom',
  display: 'swap',
});

export default function Layout({ children }) {
  return (
    <html className={`${inter.variable} ${customFont.variable}`}>
      <body className={inter.className}>{children}</body>
    </html>
  );
}
```

```typescript
// tailwind.config.ts
export default {
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-inter)', 'system-ui', 'sans-serif'],
      },
    },
  },
};
```

**Anti-patterns:**
```tsx
// ❌ Google Fonts via <link> — external request, causes CLS
<link href="https://fonts.googleapis.com/css2?family=Inter" rel="stylesheet" />

// ❌ @import in CSS — blocks rendering
@import url('https://fonts.googleapis.com/...');

// ✅ always next/font — zero runtime requests, built-in CLS prevention
```

---

## 8. Script Optimization

```tsx
import Script from 'next/script';

// afterInteractive (default for analytics) — loads after page is interactive
<Script src="https://www.gtm.js?id=GTM-XXXX" strategy="afterInteractive" />

// lazyOnload — loads during browser idle time (non-critical third parties)
<Script src="https://widget.example.com/embed.js" strategy="lazyOnload" />

// Inline scripts MUST have an id
<Script id="analytics-init" strategy="afterInteractive">
  {`window.dataLayer = window.dataLayer || [];`}
</Script>

// beforeInteractive — ONLY for critical polyfills (rare, blocks hydration)
```

### Google Analytics 4 (zero performance impact)

```tsx
import { GoogleAnalytics } from '@next/third-parties/google';
// app/layout.tsx body:
<GoogleAnalytics gaId="G-XXXXXXXXXX" />
```

---

## 9. Bundle Optimization

```tsx
// Dynamic imports — code splitting
const HeavyChart = dynamic(() => import('@/components/heavy-chart'), {
  loading: () => <Skeleton className="h-[400px]" />,
  ssr: false,
});

// Avoid barrel files
// ❌ import { Button, Input } from '@/components';
// ✅ import { Button } from '@/components/ui/button';
```

```bash
# Bundle analyzer
bun add -D @next/bundle-analyzer
ANALYZE=true bun run build
```

---

## 10. Caching for SEO (Next.js 16)

```typescript
// Requires cacheComponents: true in next.config.ts
import { cacheLife, cacheTag } from 'next/cache';

export async function HeroSection() {
  'use cache';
  cacheTag('hero', 'homepage');
  cacheLife('days');       // 5min stale, 1day revalidate — in static shell
  const data = await getCMSContent('hero');
  return <Hero data={data} />;
}
```

**Cache profile by content:** news → `seconds`, blog → `hours`, marketing → `days`, legal → `max`

**Invalidate on CMS publish:**
```typescript
// app/api/revalidate/route.ts
export async function POST(request: Request) {
  const secret = request.headers.get('x-revalidate-secret');
  if (secret !== process.env.REVALIDATE_SECRET)
    return Response.json({ error: 'Unauthorized' }, { status: 401 });
  const { tag } = await request.json();
  revalidateTag(tag, 'max');
  return Response.json({ revalidated: true });
}
```

---

## 11. Web Vitals Monitoring

```bash
bun add web-vitals
```

```typescript
// components/web-vitals.tsx
'use client';
import { useEffect } from 'react';
import { onCLS, onINP, onLCP, onFCP, onTTFB, type Metric } from 'web-vitals';

function sendToAnalytics(metric: Metric) {
  if (typeof window.gtag === 'function') {
    window.gtag('event', metric.name, {
      value: Math.round(metric.name === 'CLS' ? metric.value * 1000 : metric.value),
      event_category: 'Web Vitals',
      event_label: metric.id,
      non_interaction: true,
    });
  }
  if (process.env.NODE_ENV === 'development') {
    console.log(`[CWV] ${metric.name}: ${metric.value.toFixed(2)}`);
  }
}

export function WebVitals() {
  useEffect(() => {
    onCLS(sendToAnalytics);
    onINP(sendToAnalytics);
    onLCP(sendToAnalytics);
    onFCP(sendToAnalytics);
    onTTFB(sendToAnalytics);
  }, []);
  return null;
}
```

```tsx
// app/layout.tsx
import { WebVitals } from '@/components/web-vitals';
export default function Layout({ children }) {
  return <html><body>{children}<WebVitals /></body></html>;
}
```

---

## 12. Rendering Strategy Decision

```
Same content for all users?
├── YES → Rarely changes?
│   ├── YES → SSG (generateStaticParams) — best SEO + perf
│   └── NO  → 'use cache' with appropriate cacheLife
└── NO  → Depends on auth?
    ├── YES → SSR + auth check (Server Component, dynamic)
    └── NO  → SSR shell + CSR for user-specific data
              (NEVER CSR for SEO-indexed content)
```

| Strategy | SEO | Perf | Use case |
|---|---|---|---|
| SSG (`generateStaticParams`) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Blog, docs, product pages |
| `'use cache'` | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | CMS content, dynamic but cacheable |
| SSR (default Server Component) | ⭐⭐⭐⭐ | ⭐⭐⭐ | Auth pages, real-time prices |
| CSR (`'use client'` + fetch) | ⭐ | ⭐⭐ | Dashboards, user-private only |

**NEVER use CSR for content that needs Google indexing.**

---

## 13. Security Headers (SEO-relevant)

```typescript
// next.config.ts
async headers() {
  return [{
    source: '/(.*)',
    headers: [
      { key: 'X-Frame-Options', value: 'DENY' },
      { key: 'X-Content-Type-Options', value: 'nosniff' },
      { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
      { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
    ],
  }];
}
```

---

## 14. SEO Anti-patterns

```tsx
// ❌ CSR for SEO content — Google sees empty div
'use client';
useEffect(() => { fetch('/api/product').then(...); }, []);

// ❌ Duplicate content without canonical
// /products/widget + /products/widget?ref=homepage → same content, no canonical

// ❌ Blocking /_next/ in robots.txt
disallow: ['/_next/']   // breaks CSS/JS rendering for crawlers

// ❌ Missing metadataBase
openGraph: { images: ['/og.png'] }  // resolves to relative URL — broken

// ❌ noindex on pages you want indexed
robots: { index: false }   // on a product page — removes from Google
```

---

## 15. Verification Checklist

### Metadata
- [ ] `metadataBase` set in root layout
- [ ] Title template configured
- [ ] All pages: unique `<title>` + `<meta name="description">`
- [ ] OG image (1200×630) — file convention or metadata
- [ ] Canonical on every indexable page
- [ ] `viewport` is a **separate export** (not inside metadata)

### Technical SEO
- [ ] `app/sitemap.ts` includes all indexable pages
- [ ] `app/robots.ts` — `/_next/` NOT blocked
- [ ] JSON-LD on key pages (Organization, Product/Article, FAQ)
- [ ] hreflang for all locales (if i18n)
- [ ] HTTPS enforced (HSTS header)
- [ ] No duplicate content without canonical

### Core Web Vitals
- [ ] LCP image has `priority` prop
- [ ] All images have `width`/`height` or `fill` with sized container
- [ ] Fonts loaded via `next/font`
- [ ] Analytics/GTM loaded with `strategy="afterInteractive"`
- [ ] Web Vitals reporting set up
- [ ] PageSpeed Insights checked on production URL

### Performance
- [ ] Bundle analyzer run — no unexpectedly large chunks
- [ ] No barrel file imports in Client Components
- [ ] Heavy components use `dynamic()` with loading fallback
- [ ] SEO pages use Server Components (not CSR)
- [ ] Image `sizes` attribute matches rendered dimensions
