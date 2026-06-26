---
name: nextjs-react-best-practices
description: >
  React and Next.js performance optimization — 70 rules from Vercel Engineering
  across 8 categories. Use when eliminating data waterfalls, reducing bundle size,
  preventing unnecessary re-renders, or optimizing Server Components.
  Triggers on: Promise.all, Suspense, useMemo, dynamic imports, barrel imports,
  bundle analysis, re-render profiling.
argument-hint: "[component or performance issue]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# React & Next.js Performance Best Practices

> Source: laguagu/claude-code-nextjs-skills — Vercel Engineering, 70 rules.

---

## Priority Order

| Priority | Category | Impact |
|---|---|---|
| 1 | Eliminating Waterfalls | CRITICAL |
| 2 | Bundle Size | CRITICAL |
| 3 | Server-side | HIGH |
| 4 | Client-side Data | MEDIUM-HIGH |
| 5 | Re-renders | MEDIUM |
| 6 | Rendering | MEDIUM |
| 7 | JavaScript | LOW-MEDIUM |
| 8 | Advanced | LOW |

---

## 1. Eliminating Waterfalls (CRITICAL)

```tsx
// ❌ Sequential (300ms)
const user = await getUser(id);
const posts = await getPosts(id);

// ✅ Parallel (100ms)
const [user, posts] = await Promise.all([getUser(id), getPosts(id)]);

// ✅ Start early, await late
const userPromise = getUser(id);
const postsPromise = getPosts(id);
const [user, posts] = await Promise.all([userPromise, postsPromise]);

// ✅ Check cheap sync conditions before awaiting
async function processOrder(orderId: string) {
  if (!orderId || !isValidUUID(orderId)) return null;  // cheap first
  return await fetchOrder(orderId);                    // expensive only if needed
}

// ✅ Suspense for streaming independent content
export default function Dashboard() {
  return (
    <>
      <Header />
      <Suspense fallback={<StatsSkeleton />}><Stats /></Suspense>
      <Suspense fallback={<ActivitySkeleton />}><RecentActivity /></Suspense>
    </>
  );
}
```

---

## 2. Bundle Size (CRITICAL)

```typescript
// ❌ Barrel import — pulls entire tree
import { Button, Input, Modal } from '@/components';

// ✅ Direct import — tree-shaken
import { Button } from '@/components/ui/button';

// ✅ Dynamic import for heavy components
const Chart = dynamic(() => import('@/components/chart'), {
  loading: () => <Skeleton className="h-64" />,
  ssr: false,
});

// ✅ Defer third-party analytics after hydration
useEffect(() => {
  import('mixpanel-browser').then(({ default: mp }) => mp.init('TOKEN'));
}, []);

// ✅ Preload on hover for perceived performance
const handleMouseEnter = () => {
  router.prefetch(`/products/${slug}`);
};
```

**Bundle Analyzer:**
```bash
bun add -D @next/bundle-analyzer
ANALYZE=true bun run build
```

---

## 3. Server-side (HIGH)

```typescript
// ✅ React.cache() — deduplicate per-request
import { cache } from 'react';
const getUser = cache(async (id: string) => db.users.findUnique({ where: { id } }));
// Both calls in same render hit DB only once

// ✅ Hoist static I/O to module level
const configPromise = fetch('https://api.example.com/config').then(r => r.json());
export default async function Layout({ children }) {
  const config = await configPromise;  // resolves instantly after first request
  return <div>{children}</div>;
}

// ✅ Minimize data serialized to client
// ❌ <ClientComponent user={user} />   — 50 fields sent to client
// ✅ <ClientComponent name={user.name} avatar={user.avatar} />

// ✅ after() for non-blocking post-response work
import { after } from 'next/server';
export async function createPost(formData: FormData) {
  'use server';
  const post = await db.posts.create({ data: formData });
  after(async () => {
    await sendEmailNotification(post);  // doesn't block user
    await updateSearchIndex(post);
  });
}
```

---

## 4. Re-renders (MEDIUM)

```tsx
// ✅ React.memo for expensive components
const ExpensiveCard = React.memo(function Card({ product }) {
  return <Card>{/* complex rendering */}</Card>;
});

// ✅ Hoist non-primitive default props (prevents memo re-render)
const EMPTY_ITEMS: string[] = [];
<Child items={EMPTY_ITEMS} />   // stable reference, not new [] every render

// ✅ useDeferredValue — slow list won't block input
function SearchResults({ query }: { query: string }) {
  const deferredQuery = useDeferredValue(query);
  const results = expensiveFilter(deferredQuery);
  return <List items={results} />;
}

// ✅ useTransition — mark non-urgent state updates
const [isPending, startTransition] = useTransition();
startTransition(() => setTab('details'));

// ✅ Functional setState — stable callback, no dependency on state
// ❌ const increment = useCallback(() => setCount(count + 1), [count]);
// ✅
const increment = useCallback(() => setCount(c => c + 1), []);

// ✅ Primitive dependencies in effects
// ❌ useEffect(() => fetchUser(user), [user]);    // object ref changes every render
// ✅
useEffect(() => fetchUser(userId), [userId]);       // string — stable

// ✅ No inline components
// ❌ function Parent() { function Item() { ... }; return <Item /> }
function Item({ item }: { item: Product }) { return <li>{item.name}</li>; }
function Parent({ items }: { items: Product[] }) {
  return <ul>{items.map(item => <Item key={item.id} item={item} />)}</ul>;
}
```

---

## 5. JavaScript Performance (LOW-MEDIUM)

```typescript
// ✅ Set/Map for O(1) lookups
const adminSet = new Set(adminList);
const isAdmin = adminSet.has(userId);   // O(1) vs O(n) includes()

// ✅ flatMap = filter + map in one pass
const activeNames = items.flatMap(item => item.active ? [item.name] : []);

// ✅ Early return — avoid deep nesting
function process(order) {
  if (!order) return null;
  if (order.items.length === 0) return null;
  if (order.status !== 'pending') return null;
  return processItems(order.items);
}

// ✅ requestIdleCallback for non-critical work
if ('requestIdleCallback' in window) {
  requestIdleCallback(() => sendAnalytics(page));
}
```

---

## 6. Rendering (MEDIUM)

```css
/* ✅ Animate transform/opacity, NOT layout properties */
.box { transition: transform 0.3s, opacity 0.3s; }  /* GPU — no layout thrash */
/* ❌ .box { transition: width 0.3s, top 0.3s; }    — triggers layout */

/* ✅ content-visibility for long lists */
.list-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 200px;
}
```

```tsx
// ✅ Ternary over && (avoids rendering "0")
{count > 0 ? <Badge>{count}</Badge> : null}
// ❌ {count && <Badge>{count}</Badge>}  — renders "0" if count is 0

// ✅ Inline script for client-only data (prevents hydration flicker)
<script dangerouslySetInnerHTML={{
  __html: `document.documentElement.setAttribute('data-theme',
    localStorage.getItem('theme') ?? 'light');`
}} />
```

---

## Quick Reference Card

```typescript
// Waterfall          → Promise.all([a(), b(), c()])
// Barrel import      → import directly from file, not index
// Dynamic import     → dynamic(() => import('./heavy'))
// Dedup per-request  → React.cache(async (id) => ...)
// Re-render: memo    → React.memo(Component)
// Re-render: state   → setCount(c => c + 1)
// Re-render: deps    → useEffect(() => {}, [primitiveId])
// Lookup             → new Set(arr).has(item)
// Filter+map         → arr.flatMap(x => x.active ? [x.name] : [])
// Conditional render → condition ? <A /> : null
```
