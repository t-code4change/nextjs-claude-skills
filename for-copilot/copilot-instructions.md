# Next.js Coding Instructions

## Components
- Default Server Components. `'use client'` only for interactivity (useState, useEffect, browser APIs)
- Never import Server Components inside Client Components

## Data & Mutations  
- Data fetching: Server Components only (not useEffect)
- Parallel fetches: Promise.all()
- Server Actions: mutations only (`'use server'`), never for reading data
- Next.js 15+: await params, cookies(), headers()

## SEO (required on every page)
- metadataBase in root layout
- viewport as separate export (not inside metadata)
- generateMetadata() for dynamic routes
- Canonical URL via alternates.canonical
- JSON-LD on key pages (Organization, Product, Article, FAQ)
- Never disallow /_next/ in robots.txt

## Images
- next/image always (never <img>)
- priority on LCP image only
- width+height or fill+container — never skip dimensions
- sizes attribute matching actual rendered size

## Fonts & Scripts
- next/font only (never <link> Google Fonts)
- next/script with strategy="afterInteractive" for analytics

## Performance
- No barrel file imports in Client Components
- dynamic() for heavy components
- Animate transform/opacity, not width/height/top

## TypeScript
- Never use `any`
