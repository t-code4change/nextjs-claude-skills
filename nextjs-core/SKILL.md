---
name: nextjs-core
description: >
  Next.js App Router fundamentals and anti-patterns. Use when reviewing code for best
  practices, debugging routing issues, migrating from Pages Router, handling Server vs
  Client component boundaries, implementing Server Actions, or fixing hydration errors.
  Synthesized from wsimmonds/claude-nextjs-skills (eval-validated, 76-78% pass rate).
argument-hint: "[component, page, or error]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Next.js Core Patterns & Anti-patterns

---

## TypeScript: NEVER Use `any`

```typescript
// ❌ WRONG
function handleSubmit(e: any) { }
const data: any[] = [];

// ✅ CORRECT
function handleSubmit(e: React.FormEvent<HTMLFormElement>) { }
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => { };
// Page props (Next.js 15+)
async function Page({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
}
```

---

## Server vs Client Components

```
Need useState/useReducer/useEffect/Browser APIs/event handlers?
├── YES → 'use client' (at leaf — smallest possible boundary)
└── NO  → Server Component (default — better SEO, smaller bundle)
```

```tsx
// ✅ CORRECT: Server wraps Client
// app/page.tsx (Server Component)
export default async function Page() {
  const data = await fetchData();           // server-side
  return <div><InteractiveButton /></div>;  // only button is client
}

// ✅ CORRECT: Server Component as children of Client
<Modal>
  <ServerComponent />   {/* Server passed as children prop */}
</Modal>

// ❌ WRONG: Client Component imports Server Component
'use client';
import { ServerComponent } from './server'; // breaks — pass as children instead
```

---

## Anti-patterns

### 1. useEffect for Data Fetching

```tsx
// ❌ WRONG: waterfall + no SSR + bad SEO
'use client';
export default function List() {
  const [items, setItems] = useState([]);
  useEffect(() => { fetch('/api/items').then(r=>r.json()).then(setItems); }, []);
  return <ul>{items.map(i => <li key={i.id}>{i.name}</li>)}</ul>;
}

// ✅ CORRECT: Server Component — fast, cached, SEO-friendly
export default async function List() {
  const items = await getItems();
  return <ul>{items.map(i => <li key={i.id}>{i.name}</li>)}</ul>;
}
```

### 2. Browser Detection Causing Hydration Mismatch

```tsx
// ❌ WRONG: different value on server vs client → hydration error
const [isMobile, setIsMobile] = useState(
  typeof window !== 'undefined' && window.innerWidth < 768
);

// ✅ CORRECT: consistent initial state, detect after mount
const [isMobile, setIsMobile] = useState(false);
useEffect(() => {
  const check = () => setIsMobile(window.innerWidth < 768);
  check();
  window.addEventListener('resize', check);
  return () => window.removeEventListener('resize', check);
}, []);
```

### 3. Params Not Awaited (Next.js 15+)

```tsx
// ❌ WRONG: sync params (deprecated in 15, error in 16)
export default function Page({ params }: { params: { slug: string } }) {
  const slug = params.slug;
}

// ✅ CORRECT: async params
export default async function Page({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
}
```

### 4. cookies()/headers() Not Awaited

```tsx
// ❌ WRONG
const cookieStore = cookies();

// ✅ CORRECT
const cookieStore = await cookies();
const theme = cookieStore.get('theme')?.value;
```

### 5. Server Actions for Data Fetching

```tsx
// ❌ WRONG: Server Action is NOT a data fetching mechanism
'use server';
export async function getProducts() { return await db.products.findMany(); }

// ✅ CORRECT: Server Actions = mutations only
'use server';
export async function createProduct(formData: FormData): Promise<void> {
  await db.products.create({ data: parseFormData(formData) });
  revalidateTag('products');
}
```

### 6. Form Actions Must Return void

```tsx
// ❌ WRONG
'use server';
export async function submitForm(data: FormData) {
  const result = await process(data);
  return result;  // breaks progressive enhancement
}

// ✅ CORRECT
'use server';
export async function submitForm(data: FormData): Promise<void> {
  await process(data);
  redirect('/success');
}
```

---

## Async Patterns

### Eliminate Waterfalls

```tsx
// ❌ WRONG: sequential — 300ms
const user = await getUser();
const posts = await getPosts();
const comments = await getComments();

// ✅ CORRECT: parallel — ~100ms
const [user, posts, comments] = await Promise.all([
  getUser(), getPosts(), getComments(),
]);
```

### Suspense for Streaming

```tsx
export default function Page() {
  return (
    <>
      <HeroSection />                       {/* immediate */}
      <Suspense fallback={<Skeleton />}>
        <UserDashboard />                   {/* streams independently */}
      </Suspense>
      <Suspense fallback={<Skeleton />}>
        <RecentActivity />                  {/* streams independently */}
      </Suspense>
    </>
  );
}
```

---

## Routing Patterns

### Route Groups

```
app/
├── (marketing)/layout.tsx   ← marketing header/footer
│   ├── page.tsx             ← /
│   └── about/page.tsx       ← /about
└── (dashboard)/layout.tsx   ← sidebar
    └── dashboard/page.tsx   ← /dashboard
```

### Dynamic + Catch-all

```tsx
// app/blog/[slug]/page.tsx
export default async function Post({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
}

// app/shop/[...categories]/page.tsx
export default async function Shop({ params }: { params: Promise<{ categories: string[] }> }) {
  const { categories } = await params;  // ['electronics', 'phones']
}
```

### Route Handlers

```typescript
// app/api/products/route.ts
export async function GET(request: NextRequest) {
  const category = request.nextUrl.searchParams.get('category');
  return NextResponse.json(await getProducts({ category }));
}

export async function POST(request: NextRequest) {
  const session = await getSession(request);
  if (!session) return new Response('Unauthorized', { status: 401 });
  const body = await request.json();
  return NextResponse.json(await createProduct(body), { status: 201 });
}
```

---

## Hydration Error Prevention

```tsx
// ❌ Date formatted differently server vs client
<span>{date.toLocaleDateString()}</span>
// ✅ Fix: consistent locale
<span>{new Intl.DateTimeFormat('en-US').format(date)}</span>

// ❌ Math.random() / Date.now() in render
<div key={Math.random()}>
// ✅ Fix: stable keys from data
<div key={item.id}>

// ❌ localStorage in render
const theme = localStorage.getItem('theme');
// ✅ Fix: read in useEffect
useEffect(() => setTheme(localStorage.getItem('theme') ?? 'light'), []);

// ❌ Invalid HTML nesting
<p><div>Content</div></p>
// ✅ Fix
<div><div>Content</div></div>
```

---

## Error Handling

```tsx
// app/error.tsx
'use client';
export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return <button onClick={reset}>Try again</button>;
}

// app/not-found.tsx
export default function NotFound() { return <div>Page not found</div>; }

// Trigger 404 from Server Component
import { notFound } from 'next/navigation';
if (!product) notFound();
```
