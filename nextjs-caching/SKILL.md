---
name: nextjs-caching
description: >
  Next.js Cache Components and Partial Prerendering (PPR). Use when implementing
  'use cache' directive, cacheLife() profiles, cacheTag()/updateTag() invalidation,
  PPR static shells with dynamic streaming, or debugging cache issues.
  Auto-activates in projects with cacheComponents: true in next.config.ts.
argument-hint: "[pattern or component]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Next.js Caching (Cache Components)

> Requires: `cacheComponents: true` in `next.config.ts` (Next.js 16).

---

## Project Detection

```bash
grep -r "cacheComponents" next.config.* 2>/dev/null
```

---

## Enable

```typescript
// next.config.ts
const nextConfig: NextConfig = { cacheComponents: true };
export default nextConfig;
```

---

## Decision Steps

1. Does component fetch data? No → skip. Yes → continue.
2. Depends on `cookies()`/`headers()`/`searchParams`? No → step 3. Yes → step 4.
3. Same data for all users? Yes → `'use cache'` + `cacheTag()` + `cacheLife()`. No → `<Suspense>`.
4. Can extract runtime data as args? Yes → pass outside cache. No → `'use cache: private'` (last resort).

---

## Core APIs

### `'use cache'` Directive

```tsx
async function BlogPosts() {
  'use cache';        // MUST be first statement; function MUST be async
  cacheTag('posts');
  cacheLife('hours');
  return await db.posts.findMany();
}
```

### `cacheLife()` Profiles

```tsx
cacheLife('seconds');  // stale:30s  | revalidate:1s   | expire:1m
cacheLife('minutes');  // stale:5m   | revalidate:1m   | expire:1h
cacheLife('hours');    // stale:5m   | revalidate:1h   | expire:1d
cacheLife('days');     // stale:5m   | revalidate:1d   | expire:1w
cacheLife('weeks');    // stale:5m   | revalidate:1w   | expire:30d
cacheLife('max');      // stale:5m   | revalidate:30d  | expire:1y
// Custom:
cacheLife({ stale: 60, revalidate: 3600, expire: 86400 });
```

**By content type:** news → `seconds`, blog/docs → `hours`, marketing → `days`, legal → `max`

### `cacheTag()` + Invalidation

```tsx
// Tag
async function ProductList({ category }: { category: string }) {
  'use cache';
  cacheTag('products', `category-${category}`);
  cacheLife('hours');
  return await db.products.findMany({ where: { category } });
}

// Invalidate — Server Action (immediate, read-your-own-writes)
'use server';
export async function createProduct(formData: FormData): Promise<void> {
  await db.products.create({ data: parseFormData(formData) });
  updateTag('products');
}

// Invalidate — Route Handler / webhook (stale-while-revalidate)
export async function POST(request: Request) {
  const { tag } = await request.json();
  revalidateTag(tag, 'max');  // two-arg form — single arg is DEPRECATED
  return Response.json({ revalidated: true });
}
```

---

## Server Actions vs Data Fetching (CRITICAL)

```tsx
// ❌ WRONG: Server Action for data fetch
'use server';
export async function getProducts() { return await db.products.findMany(); }

// ✅ CORRECT: cached data function
export async function getProducts() {
  'use cache';
  cacheTag('products');
  cacheLife('hours');
  return await db.products.findMany();
}

// ✅ CORRECT: Server Action for mutation only
'use server';
export async function createProduct(formData: FormData): Promise<void> {
  await db.products.create({ data: formData });
  updateTag('products');
}
```

---

## PPR Pattern

```tsx
export default async function ProductPage({ params }) {
  const { id } = await params;
  return (
    <>
      <ProductHeader />                    {/* static */}
      <CachedProductDetails id={id} />     {/* 'use cache' — in static shell */}
      <Suspense fallback={<Skeleton />}>
        <UserCart />                        {/* dynamic — streams after load */}
      </Suspense>
    </>
  );
}

async function CachedProductDetails({ id }: { id: string }) {
  'use cache';
  cacheTag(`product-${id}`);
  cacheLife('hours');
  const product = await db.products.findUnique({ where: { id } });
  return <ProductInfo product={product} />;
}
```

---

## Runtime Data Pattern (cookies inside cache)

```tsx
// ❌ WRONG: cookies() inside 'use cache'
async function UserData() {
  'use cache';
  const cookieStore = await cookies();  // ERROR
}

// ✅ CORRECT: extract outside, pass as arg
async function UserDataWrapper() {
  const cookieStore = await cookies();
  const userId = cookieStore.get('userId')?.value;
  return <CachedUserData userId={userId} />;
}

async function CachedUserData({ userId }: { userId: string }) {
  'use cache';
  cacheTag(`user-${userId}`);
  cacheLife('minutes');
  return await getUser(userId);
}
```

---

## Review Checklist

- [ ] `cacheComponents: true` in `next.config.ts`
- [ ] All `'use cache'` functions are `async`
- [ ] `'use cache'` is first statement
- [ ] `cacheTag()` present (enables targeted invalidation)
- [ ] `cacheLife()` present (don't rely on defaults)
- [ ] `cookies()`/`headers()` NOT inside `'use cache'` scope
- [ ] Server Actions call `updateTag()` after mutations
- [ ] Dynamic components wrapped in `<Suspense>`
- [ ] `revalidateTag(tag, profile)` — two-arg form (not deprecated single-arg)
- [ ] Server Actions return `void`, never used for data fetching
