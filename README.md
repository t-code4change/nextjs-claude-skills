# nextjs-claude-skills

Production-grade Claude Code skill collection for Next.js App Router projects.
**Primary focus: SEO and Web Performance.**

Built by synthesizing the best patterns from community skill repos + filling critical gaps.

## Skills

| Skill | Focus | Lines |
|---|---|---|
| [`nextjs-seo-performance`](./nextjs-seo-performance/) | SEO, Core Web Vitals, Image/Font/Script optimization | ~1300 |
| [`nextjs-caching`](./nextjs-caching/) | `use cache`, PPR, cache invalidation (Next.js 16) | ~320 |
| [`nextjs-core`](./nextjs-core/) | App Router fundamentals, anti-patterns, Server/Client boundaries | ~520 |
| [`nextjs-react-best-practices`](./nextjs-react-best-practices/) | 70 performance rules, waterfall elimination, bundle optimization | ~490 |

## Installation

Copy skills into your project's `.claude/skills/` folder:

```bash
# Clone
git clone https://github.com/t-code4change/nextjs-claude-skills.git

# Install all skills
cp -r nextjs-claude-skills/nextjs-seo-performance  your-project/.claude/skills/
cp -r nextjs-claude-skills/nextjs-caching          your-project/.claude/skills/
cp -r nextjs-claude-skills/nextjs-core             your-project/.claude/skills/
cp -r nextjs-claude-skills/nextjs-react-best-practices your-project/.claude/skills/
```

## What's Covered

### SEO (Flagship — `nextjs-seo-performance`)
- Metadata API — static, dynamic, `generateMetadata()`
- Open Graph + Twitter Cards (file conventions + `ImageResponse`)
- Structured Data / JSON-LD — Organization, Product, Article, FAQ, BreadcrumbList
- Sitemap + robots.txt (TypeScript API)
- Canonical URLs + hreflang (i18n SEO)
- Dynamic OG images with `ImageResponse`
- AI crawlers strategy (GPTBot vs OAI-SearchBot vs PerplexityBot)
- Core Web Vitals — LCP, INP, CLS: targets, causes, fixes
- `next/image` — all optimization patterns, `sizes` attribute guide
- `next/font` — zero CLS font loading
- `next/script` — third-party script strategies
- Bundle size optimization — dynamic imports, barrel file avoidance
- Web Vitals reporting — production monitoring with `web-vitals` library
- Security headers (HSTS, X-Frame-Options)
- Rendering strategy decision tree

### Caching (`nextjs-caching`)
- `'use cache'` directive patterns (Next.js 16)
- `cacheLife()` profiles — choosing by content type
- `cacheTag()` + `updateTag()` + `revalidateTag()` invalidation
- PPR (Partial Prerendering) — static shell + dynamic streaming
- Server Actions vs data fetching (critical distinction)

### Core Patterns (`nextjs-core`)
- Server vs Client component decision tree
- Anti-patterns — useEffect misuse, hydration errors, browser detection
- Async params/cookies/headers (Next.js 15+)
- Route Handlers, Parallel Routes, Intercepting Routes
- Middleware/Proxy patterns

### React Performance (`nextjs-react-best-practices`)
- Waterfall elimination with `Promise.all`, `Suspense`
- Bundle optimization — barrel imports, dynamic imports
- `React.cache()` for per-request deduplication
- Re-render optimization — `useDeferredValue`, `useTransition`, `React.memo`
- 70 rules from Vercel Engineering

## Stack Compatibility

- Next.js 14+ (App Router)
- Next.js 15+ (async params/cookies/headers)
- Next.js 16+ (Cache Components — `cacheComponents: true`)
- TypeScript strict mode
- Tailwind CSS

## Credits

Synthesized from:
- [wsimmonds/claude-nextjs-skills](https://github.com/wsimmonds/claude-nextjs-skills) — anti-patterns, routing (76–78% Vercel eval pass rate)
- [laguagu/claude-code-nextjs-skills](https://github.com/laguagu/claude-code-nextjs-skills) — SEO, caching, React best practices
