# Next.js Best Practices — AI Agent Rules

This file is automatically read by Codex and OpenAI-compatible agents.
Source: https://github.com/t-code4change/nextjs-claude-skills

---

## CRITICAL: Server vs Client Components

- Default to Server Components — no `'use client'` unless component needs useState/useEffect/browser APIs
- Place `'use client'` at leaf components only (smallest boundary)
- Never import Server Components into Client Components — pass as `children` instead
- Props from Server to Client must be serializable

## CRITICAL: Data Fetching

- Fetch data in Server Components — never useEffect for data fetching
- Use `Promise.all()` for parallel fetches — never sequential awaits
- Server Actions are for MUTATIONS ONLY — never use for data fetching
- Next.js 15+: always `await params`, `await cookies()`, `await headers()`

## SEO — Always Apply

- Every page needs: unique `<title>`, `<meta description>`, canonical URL
- `metadataBase` must be set in root layout
- `viewport` must be a separate export — never inside `metadata` object
- Use `generateMetadata()` for dynamic routes
- Never use CSR (`useEffect` fetch) for SEO-indexed content
- Never block `/_next/` in robots.txt
- Set canonical URL on every indexable page to prevent duplicate content
- Add JSON-LD structured data on key pages

## Images

- Always use `next/image` — never `<img>` tag
- LCP image must have `priority` prop
- All images need explicit `width`/`height` or `fill` with sized container
- Set `sizes` attribute to match actual rendered dimensions
- Use `quality={85}` for hero images, default 75 for others

## Fonts

- Always use `next/font` — never Google Fonts `<link>` or `@import`
- Always set `display: 'swap'`

## Scripts / Analytics

- Load analytics with `strategy="afterInteractive"` via `next/script`
- Use `@next/third-parties/google` for GA4

## Bundle

- Import directly from file, not from barrel index files
- Use `dynamic()` for heavy components that aren't needed on first load

## TypeScript

- Never use `any` type
- Page props in Next.js 15+: `params: Promise<{ slug: string }>`

## Caching (Next.js 16, cacheComponents: true)

- `'use cache'` must be first statement, function must be async
- Always pair with `cacheTag()` and `cacheLife()`
- Never call `cookies()`/`headers()` inside `'use cache'` scope
- Call `updateTag()` after mutations in Server Actions
- Wrap dynamic content in `<Suspense>`

## Core Web Vitals Targets

- LCP < 2.5s, INP < 200ms, CLS < 0.1
- Never skip `priority` on the LCP image
- Never introduce layout shift — always reserve space for async content
- Animate `transform`/`opacity`, never layout properties
