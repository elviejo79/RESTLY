# RESTLY — Explained for TypeScript Developers

## The Core Insight

The router is a hash table where **keys are URL patterns** (`/todos`, `/todos/:id`) and **values are data pipelines**. Lookup uses pattern matching — the stored key `/todos/:id` "equals" the query `/todos/42` and extracts `{ id: "42" }`. No separate router abstraction — storage combinators all the way down.

```typescript
// Conceptually:
type Router = Map<URLPattern, Pipeline<string, JSONObject>>
// where Map.get() uses template matching, not ===
```

## Architecture: Three Layers

### Layer 1 — Core Protocol (no HTTP, no JSON)

A generic interface for key-value storage with REST semantics:

```typescript
// Eiffel: RESTLY_PROTOCOL [K, V]
interface Protocol<K, V> {
  item(key: K): V          // GET one
  hasKey(key: K): boolean
  extend(value: V, key: K) // INSERT (precondition: key absent)
  put(value: V, key: K)    // UPDATE (precondition: key present)
  force(value: V, key: K)  // UPSERT
  remove(key: K)           // DELETE one
}
```

Key distinction from a plain `Map`: `extend` throws if the key exists, `put` throws if it doesn't. Enforced by contracts (preconditions) — runtime assertions that are part of the type's specification.

Concrete storage is `RESTLY_HASH_TABLE` — a wrapper around Eiffel's hash table conforming to this protocol:

```typescript
class HashTableStorage<K, V> implements Protocol<K, V> { /* Map wrapper */ }
```

### Layer 2 — Combinators (composition, still no HTTP)

Combinators wrap a protocol and add behavior. Like middleware, but for storage:

```typescript
// Eiffel: RESTLY_BASIC_COMBINATOR [K, R, S]
// R = Representation (outside), S = Store (inside)
class BasicCombinator<K, R, S> implements Protocol<K, R> {
  constructor(
    private front: Protocol<K, R>,
    private back: Protocol<K, S>,
    private converter: Converter<R, S>
  ) {}

  item(key: K): R {
    return this.converter.toRepresentation(this.back.item(key))
  }
  // each verb delegates with conversion
}
```

The cache combinator (`RESTLY_CACHE`) sits in front of a protocol and caches reads.

### Layer 3 — Pipeline Front (where capabilities live)

Three capability interfaces exist on top of the base protocol. They **only live at the front** of a pipeline — everything behind is pure `Protocol`:

```typescript
// Eiffel: RESTLY_EXTENDABLE — server-minted keys for POST
interface Extendable<K, V> {
  extendNew(value: V, requestId: string): void  // idempotent!
  extendRequests: Map<string, K>  // requestId → generated key
  freshKey(): K  // abstract — auto-increment, UUID, etc.
}

// Eiffel: RESTLY_PATCHABLE — partial updates for PATCH
interface Patchable<K, V> {
  merge(patch: V, key: K): void  // RFC 7386: absent field = unchanged
}

// Eiffel: RESTLY_TRAVERSABLE — iteration for GET-list and DELETE-all
interface Traversable<K, V> {
  [Symbol.iterator](): IterableIterator<[K, V]>  // must expose KEYS
  count: number
  wipeOut(): void
}
```

The pipeline front combines everything:

```typescript
// Eiffel: RESTLY_PIPELINE_FRONT [K_Rep, V_Rep, K_Store, V_Store]
class PipelineFront<KR, VR, KS, VS>
  implements Protocol<KR, VR>, Extendable<KR, VR>, Patchable<KR, VR>, Traversable<KR, VR>
{
  constructor(
    private inner: Protocol<KS, VS>,
    private keyConverter: Converter<KR, KS>,
    private valueConverter: Converter<VR, VS>
  ) {}
  // Every verb converts keys/values across the boundary
}
```

**Capabilities don't leak through the pipeline.** The inner storage is a plain `Protocol`. The front is the only place that knows about POST-id-minting, PATCH-merging, or collection-iteration.

### Layer 4 — EWF Bridge (HTTP)

The bridge maps HTTP verbs to protocol capabilities:

| Route kind       | HTTP verb | Requires                              |
|------------------|-----------|---------------------------------------|
| `mountElement`   | GET       | `Protocol.item` / `hasKey`            |
| `mountElement`   | PATCH     | `Patchable.merge`                     |
| `mountElement`   | DELETE    | `Protocol.remove`                     |
| `mountCollection`| GET       | `Traversable[Symbol.iterator]`        |
| `mountCollection`| POST      | `Extendable.extendNew`                |
| `mountCollection`| DELETE    | `Traversable.wipeOut`                 |
| anything else    |           | **405 Method Not Allowed**            |

Mounting:

```typescript
// Eiffel: RESTLY_EWF_MOUNTING
server.mountCollection("/todos",      todos)
server.mountElement("/todos/{id}",    todos)
// shorthand:
server.mountResource("/todos", todos) // = both of the above
```

Both routes share one pipeline front instance — same storage.

## Design Decisions Worth Stealing

### 1. Errors from contracts, not try/catch

Precondition tags encode the HTTP status:

```
error_404_not_found    → 404
error_409_conflict     → 409
(PRECONDITION_VIOLATION without a code) → 412
(anything else)        → 500
```

The handler catches the violation, parses the tag, returns the status. The domain layer defines what's illegal; the HTTP layer only translates the failure kind.

In TS you'd use typed error classes:

```typescript
class NotFoundError extends Error { status = 404 }
class ConflictError extends Error { status = 409 }
// handler: catch(e) → res.status(e.status).json({error: e.message})
```

### 2. POST idempotency at the library level

`extendNew(value, requestId)` is idempotent: calling it twice with the same `requestId` and same value is a no-op returning the original key. This is the Stripe `Idempotency-Key` pattern baked into the storage layer.

The HTTP handler mints a fresh `requestId` per request (HTTP retries aren't deduplicated in v1), but the primitive is ready for client-supplied idempotency keys later.

### 3. Converters are pure — the web layer adds web things

The `url` field in todobackend responses is added by the HTTP handler *after* conversion. Converters only know `domain <-> JSON`. Web concerns (absolute URLs, `Location` headers) stay in the web layer. Keeps the pipeline testable without a server.

### 4. PATCH is JSON-on-JSON merge, not domain-level

Instead of `{ ...existing, ...patch }` on a typed object, PATCH merges JSON values directly at the pipeline front (RFC 7386: absent field = unchanged), then converts the result to the domain type.

The domain layer never sees partial objects.

## Testing Strategy

Three layers, independently runnable:

| Layer | Tests | What |
|-------|-------|------|
| **Core** | 59 | Protocol, converters, pipeline front. No server, no JSON. |
| **Bridge** | 77 | JSON response, tag parser, JSON front + all core tests. |
| **Acceptance** | 16 | Full HTTP round-trips (todobackend npm suite). |

Key testing patterns:

- **Hold references to collaborators**: create inner storage as a variable, pass it into the pipeline front, assert on *both* views (STRING keys on the front, INTEGER keys on the inner). Verifies conversion.
- **No mocks**: every test uses real objects. Test doubles (`SAMPLE_FRONT`, `SAMPLE_ITEM`) are trivial implementations, not mock frameworks.
- **Test contracts, not internals**: only reach states through the public interface.

## Translating to TypeScript

The architecture maps directly:

1. Define `Protocol<K, V>` with REST verbs.
2. Implement with a `Map`-backed class.
3. Build `PipelineFront` wrapping a `Protocol` with key/value converters + capability interfaces.
4. Mount routes with Express/Fastify — check `instanceof Extendable` etc. at dispatch, or use a discriminated union.
5. Throw typed errors from the protocol layer, catch in the HTTP handler, map to status codes.

**What TS gives you for free** (required effort in Eiffel): structural typing (no need for a distinct `KeyConverter` type), `JSON.parse`/`JSON.stringify`, `{ ...spread }` for merging.

**What you lose**: the contract system that makes precondition-tag-to-HTTP-status mapping automatic, and compiler-checked postconditions that serve as living documentation.

## Request Flows

```
POST /todos
  → handler mints requestId
  → front.extendNew(jsonBody, requestId)
  → front.extendRequests.get(requestId) → key
  → 201 + Location header + url field

GET /todos/42
  → key conversion: "42" → 42
  → inner.item(42)
  → value conversion: TodoItem → JSON
  → handler patches url field
  → 200

PATCH /todos/42
  → front.merge(patchJson, "42")  // RFC 7386
  → 200 + full item

GET /todos
  → front[Symbol.iterator]()  // exposes [key, value] pairs
  → handler patches url on each item
  → 200 + JSON array

DELETE /todos/42 → remove("42") → 204
DELETE /todos    → wipeOut()    → 200
```

## File Layout

```
library/restly/              ← Core (no HTTP dependency)
  src/
    restly_protocol.e        ← The base interface
    protocol/                ← Capability mixins (extendable, patchable, traversable)
    combinator/              ← BasicCombinator, Cache, PipelineFront
    converter/               ← Value converters
    structures/              ← HashTableStorage
  testing/                   ← Core tests + fixtures

library/restly_ewf/          ← EWF bridge (depends on core + EWF)
  src/
    wsf_json_response.e      ← JSON response helper
    restly_ewf_mounting.e      ← Router + mount features
    restly_ewf_gateway.e     ← Verb dispatch + error mapping
    restly_json_pipeline_front.e  ← JSON merge + STRING fresh_key
  testing/                   ← Bridge tests

examples/todobackend/        ← Working app (proves the design)
  src/
    todo_item.e              ← Domain object
    todo_converter.e         ← JSON <-> TodoItem
```
