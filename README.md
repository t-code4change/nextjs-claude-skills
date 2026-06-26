# 🚀 Next.js Claude Skills

> **The most complete AI coding skill pack for Next.js** — built around the two things that actually determine if your web app succeeds: **SEO** and **Performance**.

[![Skills](https://img.shields.io/badge/skills-4_packs-blue)](#skills)
[![Next.js](https://img.shields.io/badge/Next.js-16%2B-black)](#compatibility)
[![Claude](https://img.shields.io/badge/Claude_Code-primary-orange)](#claude-code-primary--recommended)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## Why this skill pack?

Most AI coding assistants write Next.js code that **works** — but ships with broken metadata, missing structured data, unoptimized images, and Core Web Vitals scores that tank your Google rankings.

This skill pack fixes that. It gives your AI assistant deep, production-grade knowledge of:

- ✅ **Every SEO pattern** in Next.js — Metadata API, Open Graph, JSON-LD schemas, sitemap, robots.txt, canonical URLs, hreflang, dynamic OG images
- ✅ **Core Web Vitals** — exact causes of LCP/INP/CLS failures and how to fix them
- ✅ **Performance optimization** — images, fonts, scripts, bundles, caching
- ✅ **Next.js 16 Cache Components** — the new `'use cache'` directive most devs don't know yet
- ✅ **70 performance rules** from Vercel Engineering — waterfall elimination, bundle size, re-renders

Synthesized from the best community skill repos, validated against Vercel's eval suite (**76–78% pass rate**), then extended with everything they were missing.

---

## Skills included

| Skill | Focus | Size |
|---|---|---|
| 🏆 `nextjs-seo-performance` | **Flagship** — SEO + Core Web Vitals + Image/Font/Script/Monitoring | ~760 lines |
| ⚡ `nextjs-caching` | `use cache`, PPR, cache invalidation — Next.js 16 | ~190 lines |
| 🧱 `nextjs-core` | App Router, anti-patterns, Server/Client boundaries | ~280 lines |
| 🔬 `nextjs-react-best-practices` | 70 rules: waterfall, bundle, re-renders | ~245 lines |

---

## Installation

### Claude Code (Primary — Recommended)

Claude Code skills live in `.claude/skills/` inside your project. Each skill activates **automatically** when Claude detects relevant context — or invoke manually with `/skill-name`.

#### ⚡ One-command install

```bash
curl -fsSL https://raw.githubusercontent.com/t-code4change/nextjs-claude-skills/main/install.sh | bash
```

Installs all 4 skills into `.claude/skills/` in your current project directory.

#### Manual install

```bash
# Step 1: Clone
git clone --depth 1 https://github.com/t-code4change/nextjs-claude-skills.git /tmp/ncs

# Step 2: Create skills directory
mkdir -p .claude/skills

# Step 3: Copy skills
cp -r /tmp/ncs/nextjs-seo-performance       .claude/skills/
cp -r /tmp/ncs/nextjs-caching               .claude/skills/
cp -r /tmp/ncs/nextjs-core                  .claude/skills/
cp -r /tmp/ncs/nextjs-react-best-practices  .claude/skills/

# Step 4: Clean up
rm -rf /tmp/ncs
```

#### Git submodule (stays updated automatically)

```bash
git submodule add https://github.com/t-code4change/nextjs-claude-skills.git .claude/skills/nextjs-skills
```

#### Verify installation

```bash
ls .claude/skills/
# nextjs-caching  nextjs-core  nextjs-react-best-practices  nextjs-seo-performance
```

#### Invoke skills in Claude Code

Skills activate automatically. You can also call them directly in any conversation:

```
/nextjs-seo-performance       → SEO audit, metadata, Core Web Vitals, images
/nextjs-caching               → Caching strategy, use cache directive  
/nextjs-core                  → App Router patterns, anti-patterns
/nextjs-react-best-practices  → Performance optimization (70 rules)
```

---

### Cursor

```bash
mkdir -p .cursor/rules
curl -fsSL https://raw.githubusercontent.com/t-code4change/nextjs-claude-skills/main/for-cursor/nextjs.mdc \
  -o .cursor/rules/nextjs.mdc
```

Cursor applies these rules automatically to all Next.js files in your project.

---

### Codex / OpenAI Agents

```bash
curl -fsSL https://raw.githubusercontent.com/t-code4change/nextjs-claude-skills/main/AGENTS.md \
  -o AGENTS.md
```

---

### GitHub Copilot / Windsurf

```bash
# Copilot
mkdir -p .github
curl -fsSL https://raw.githubusercontent.com/t-code4change/nextjs-claude-skills/main/for-copilot/copilot-instructions.md \
  -o .github/copilot-instructions.md

# Windsurf
curl -fsSL https://raw.githubusercontent.com/t-code4change/nextjs-claude-skills/main/for-windsurf/.windsurfrules \
  -o .windsurfrules
```

---

## Quick Start — New Project

```bash
# 1. Create Next.js project
bunx --bun create-next-app@latest my-app --typescript --tailwind --app --use-bun
cd my-app

# 2. Install skills
curl -fsSL https://raw.githubusercontent.com/t-code4change/nextjs-claude-skills/main/install.sh | bash

# 3. Add shadcn/ui
bunx --bun shadcn@latest init -d

# 4. Open Claude Code — skills are ready
claude .
```

From this point, Claude will build your app with production-grade SEO and performance patterns from the very first file.

---

## What exactly does each skill teach?

### 🏆 nextjs-seo-performance — The flagship

The most comprehensive Next.js SEO + Performance skill available. Claude will never ship a page with broken metadata or a failing Core Web Vital again.

**SEO:**
- `Metadata API` — `metadataBase`, title templates, `viewport` as separate export
- `generateMetadata()` for dynamic routes — products, blog posts, any CMS content
- Open Graph + Twitter Cards — static file convention + dynamic `ImageResponse`
- **5 JSON-LD schemas** — Organization, Product, Article, FAQ, BreadcrumbList
- `app/sitemap.ts` + `app/robots.ts` — TypeScript API, correct AI crawler rules
- Canonical URLs, hreflang (i18n/multilingual SEO)
- Dynamic OG images with `ImageResponse` (Satori constraints included)

**Core Web Vitals:**
- LCP < 2.5s, INP < 200ms, CLS < 0.1 — targets + root causes + exact fixes
- Uses field data (PageSpeed Insights, Search Console) — not Lighthouse (lab-only)
- Every cause of LCP delay mapped to a fix
- Every cause of CLS mapped to a fix
- INP optimization with `useTransition`, `useDeferredValue`

**Performance:**
- `next/image` — `priority`, `sizes`, `fill`, `quality`, blur placeholder
- `next/font` — zero CLS, zero external requests
- `next/script` — `afterInteractive`, `lazyOnload`, GTM/GA4 patterns
- Bundle optimization — dynamic imports, barrel file avoidance
- Web Vitals monitoring → GA4 (production reporting)
- Rendering strategy decision tree: SSG vs `'use cache'` vs SSR vs CSR

### ⚡ nextjs-caching — Next.js 16 Cache Components

`cacheComponents: true` shipped in Next.js 16. Most developers have no idea how to use it properly. This skill does.

- Decision tree: when to `'use cache'` vs `<Suspense>` stream
- `cacheLife()` profiles mapped to content type (news → `seconds`, blog → `hours`, marketing → `days`)
- `cacheTag()` + `updateTag()` — read-your-own-writes after mutations
- `revalidateTag()` — webhook-triggered stale-while-revalidate
- PPR pattern — static shell + dynamic streaming side-by-side
- How to handle `cookies()`/`headers()` correctly outside cache scope

### 🧱 nextjs-core — App Router fundamentals

Validated against Vercel's eval suite. Catches the bugs that silently break production apps.

- Server vs Client component decision tree (minimize `'use client'` surface)
- **6 critical anti-patterns** — `useEffect` data fetch, browser detection, unnecessary client components
- Next.js 15+ async params/cookies/headers — migration from sync API
- Server Actions are for **mutations only** — never data fetching
- `Promise.all` waterfall elimination
- Suspense streaming patterns
- Hydration error prevention (dates, Math.random, localStorage in render)
- Route Handlers, Parallel Routes, Intercepting Routes

### 🔬 nextjs-react-best-practices — 70 rules

70 performance rules from Vercel Engineering, prioritized by impact.

1. **Waterfalls** — `Promise.all`, early promise start, Suspense streaming
2. **Bundle size** — no barrel imports, `dynamic()`, defer third-parties
3. **Server-side** — `React.cache()`, hoist static I/O, `after()` for non-blocking ops
4. **Re-renders** — `React.memo`, `useDeferredValue`, `useTransition`, functional setState
5. **JavaScript** — Set/Map for O(1) lookups, `flatMap`, early returns
6. **Rendering** — animate `transform` not layout props, ternary over `&&`

---

## Compatibility

| AI Tool | Support | File |
|---|---|---|
| **Claude Code** | ✅ Native | `.claude/skills/` |
| **Cursor** | ✅ Full | `.cursor/rules/nextjs.mdc` |
| **Codex / OpenAI** | ✅ Good | `AGENTS.md` |
| **GitHub Copilot** | ✅ Good | `.github/copilot-instructions.md` |
| **Windsurf** | ✅ Good | `.windsurfrules` |

| Version | Support |
|---|---|
| Next.js 14+ (App Router) | ✅ |
| Next.js 15+ (async params) | ✅ |
| Next.js 16+ (Cache Components) | ✅ |
| TypeScript strict mode | ✅ |
| React 18, 19 | ✅ |

---

## FAQ

**Do I need to restart Claude Code after installing?**
No — open a new conversation and skills are active.

**Will this slow down Claude?**
No — skills load only when triggered by relevant context.

**Can I install only specific skills?**
Yes — copy only the skill directories you want.

**Pages Router support?**
These skills focus on App Router. The `nextjs-core` skill covers Pages → App migration.

**How do I update?**
Re-run the install script, or `git pull` if using submodules.

---

## Credits

Synthesized from:
- [wsimmonds/claude-nextjs-skills](https://github.com/wsimmonds/claude-nextjs-skills) — anti-patterns, routing (76–78% Vercel eval pass rate)
- [laguagu/claude-code-nextjs-skills](https://github.com/laguagu/claude-code-nextjs-skills) — SEO, caching, React best practices

---

## License

MIT — free to use, modify, distribute.

**⭐ Star this repo if it helped you ship better Next.js apps.**
