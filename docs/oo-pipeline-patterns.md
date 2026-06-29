# Push + Queue Pipelines in Static-OO Languages

Resolved spec:
**push** (source-driven)
· **queue between every stage** (so the topology *can* go async; dead weight when sync is accepted)
· **composable** (a pipe is itself a stage)
· **typed heterogeneous stages** `PIPE[IN, OUT]`
· **one consistent reading direction**.

```
 push                    push                    push
 ───▶ [ stage A ] ──▶  | Q | ──▶ [ stage B ] ──▶ | Q | ──▶ [ sink ]
        IN→MID        bounded       MID→OUT      bounded
                      buffer                     buffer
   source drives ──────────────────────────────────────▶  reading order = data-flow order
```

The queue sitting between a *push* producer and the next stage is the async boundary:
same thread when sync, a thread/processor hand-off when async.
Nothing in the call sites changes — only the buffer's role does.

---

## 1. C# — TPL Dataflow

The closest thing any mainstream language ships to your exact spec.
Each block **owns an input queue**;
`BoundedCapacity` turns it into backpressure.

```csharp
using System.Threading.Tasks.Dataflow;

var opts = new ExecutionDataflowBlockOptions { BoundedCapacity = 16 }; // bounded queue per block
var link = new DataflowLinkOptions          { PropagateCompletion = true };

var parse  = new TransformBlock<string, int>(s => int.Parse(s), opts);  // string -> int
var square = new TransformBlock<int, long>(x => (long)x * x, opts);     // int    -> long
var sink   = new ActionBlock<long>(v => Console.WriteLine(v), opts);

parse.LinkTo(square, link);   // wire edge
square.LinkTo(sink,  link);   // wire edge

foreach (var line in source)
    await parse.SendAsync(line);   // PUSH; awaits when the downstream queue is full
parse.Complete();
await sink.Completion;
```

Composability — collapse a sub-pipeline into one stage:

```csharp
IPropagatorBlock<string, long> Pipeline()
{
    var p = new TransformBlock<string, int>(s => int.Parse(s), opts);
    var s = new TransformBlock<int, long>(x => (long)x * x, opts);
    p.LinkTo(s, link);
    return DataflowBlock.Encapsulate(p, s);   // one block; internals hidden
}
```

- **Queue** native, bounded.
- **Push** via `Post`/`SendAsync`.
- **Typed-hetero** via `TransformBlock<TIn,TOut>`.
- **Composable** via `Encapsulate`.
- **Readability**: one `LinkTo` statement per edge, top-down in data-flow order. Consistent — but *not* a single fluent expression. This is the price.
- No contracts.

## 2. Java — JDK `Flow` SPI vs. Reactor

### 2a. JDK `java.util.concurrent.Flow` (stdlib, but it's an SPI — do not use directly for app code)

`SubmissionPublisher` carries a per-subscriber buffer (default 256). A `Processor` is **both** a `Subscriber` and a `Publisher`, so you author the glue by hand:

```java
class MapProcessor<T,R> extends SubmissionPublisher<R>
        implements Flow.Processor<T,R> {
    private final Function<T,R> fn;
    private Flow.Subscription sub;
    MapProcessor(Function<T,R> fn) { this.fn = fn; }
    public void onSubscribe(Flow.Subscription s) { sub = s; s.request(1); }
    public void onNext(T item) { submit(fn.apply(item)); sub.request(1); }   // PUSH + buffer
    public void onError(Throwable t) { closeExceptionally(t); }
    public void onComplete() { close(); }
}
// wiring: source.subscribe(parse); parse.subscribe(square); square.subscribe(sink);
```

Reads source→sink (acceptable), but authoring each stage is brutal boilerplate. The SPI exists for library authors, not you.

### 2b. Reactor `Flux` (idiomatic — and it quietly nails everything)

```java
Flux.fromIterable(lines)
    .map(Integer::parseInt)            // String  -> Integer
    .map(x -> (long) x * x)            // Integer -> Long
    .publishOn(Schedulers.parallel())  // async boundary; introduces a queue
    .subscribe(System.out::println);   // PUSH, demand-driven (backpressure)
```

- Queues appear at `publishOn` / `onBackpressureBuffer`.
- **Fluent, left-to-right, in data-flow order** the best readability of the set.
- Composable via `.transform(f -> ...)`.
- Typed-hetero (`map` changes the element type).
The catch: it's a third-party library, not the language.

## 3. Eiffel — SCOOP (the queue is the language)

A stage is a `separate` object.
A feature call on a separate target is **asynchronous and logged on that processor's request queue**
— so you don't hand-roll the queue, the concurrency model *is* the queue.
And uniquely: a **precondition on a separate target becomes a wait-condition** — i.e. DbC *is* the synchronization spec.

> Schematic (not compiled — agent-call and separate-arg syntax verified by eye, not by EiffelStudio):

```eiffel
deferred class SINK [T]
feature
    put (x: T)
        require
            accepting: is_accepting   -- on a separate target this is a WAIT condition
        deferred
        end
    is_accepting: BOOLEAN deferred end
end

class STAGE [IN, OUT]
inherit SINK [IN]
create make
feature
    make (t: FUNCTION [IN, OUT]; n: separate SINK [OUT])
        do transform := t; next := n end

    put (x: IN)
        do
            forward (next, transform.item ([x]))   -- transform: IN -> OUT
        end

    is_accepting: BOOLEAN do Result := True end

feature {NONE}
    transform: FUNCTION [IN, OUT]
    next: separate SINK [OUT]
    forward (n: separate SINK [OUT]; y: OUT)
        do n.put (y) end   -- separate call => ENQUEUED on n's processor (async)
end
```

- **Queue** language-native (strongest of the set).
- **Push** via `put`.
- **Typed-hetero** via `STAGE [IN, OUT]`.
- **Composable** (separate stages chain).
- **Contracts on the queue boundary** the only entrant that does this.
- **Readability**: one feature-call per stage, data-flow order. Consistent, not a single expression.
- **Killer caveat**: AutoProof cannot verify SCOOP. You can *express* the backpressure/readiness contract; you cannot *statically verify* the concurrent program. DbC-expressible ≠ DbC-verifiable.

## 4. C++ — the fork where your requirements visibly collide

### 4a. Ranges (C++20/23) — gorgeous, and wrong for you

```cpp
#include <ranges>
auto pipe = input
          | std::views::transform([](std::string const& s){ return std::stoi(s); })   // string->int
          | std::views::transform([](int x){ return static_cast<long>(x) * x; });      // int->long
for (auto v : pipe) std::cout << v << '\n';   // PULL; lazy; single-threaded
```

Best left-to-right syntax in the entire comparison. But it is **pull**, **synchronous**, and has **no queue**. It fails your two load-bearing requirements (R-queue, R-push).

### 4b. Hand-rolled channel + threads — correct, and you're now writing an actor framework

```cpp
template <class T>
class Channel {                         // bounded blocking queue = the async boundary
    std::queue<T> q_; std::mutex m_;
    std::condition_variable not_empty_, not_full_;
    std::size_t cap_; bool closed_ = false;
public:
    explicit Channel(std::size_t cap) : cap_(cap) {}
    void push(T v) {
        std::unique_lock lk(m_);
        not_full_.wait(lk, [&]{ return q_.size() < cap_ || closed_; });
        q_.push(std::move(v)); not_empty_.notify_one();
    }
    std::optional<T> pop() {
        std::unique_lock lk(m_);
        not_empty_.wait(lk, [&]{ return !q_.empty() || closed_; });
        if (q_.empty()) return std::nullopt;
        T v = std::move(q_.front()); q_.pop(); not_full_.notify_one();
        return v;
    }
    void close() { std::lock_guard lk(m_); closed_ = true;
                   not_empty_.notify_all(); not_full_.notify_all(); }
};
// a stage = a std::jthread reading its input Channel<IN>, transforming, pushing Channel<OUT>.
```

Typed via templates, push via `push`, queue is the `Channel` you wrote. **Composability and readability both collapse**: you wire threads and channels by hand, there is no linear reading of the pipeline, and nothing in `std` blesses the construction.

---

## Comparison against your requirements

| | Queue / async | Push | Composable | Typed-hetero | One reading direction | DbC on boundary | Native vs. library |
|---|---|---|---|---|---|---|---|
| **C# TPL Dataflow** | ✓ bounded | ✓ | ✓ `Encapsulate` | ✓ | ~ stmt/edge, data-flow order | ✗ | official lib |
| **Java Reactor `Flux`** | ✓ at `publishOn` | ✓ | ✓ `transform` | ✓ | ✓✓ fluent L→R | ✗ | 3rd-party lib |
| **Java JDK `Flow`** | ✓ buffer | ✓ | ~ heavy boilerplate | ✓ | ~ wiring L→R, authoring inside-out | ✗ | stdlib (SPI) |
| **Eiffel SCOOP** | ✓✓ language-level | ✓ | ✓ | ✓ | ~ feature/stage, data-flow order | ✓✓ only one | language |
| **C++ ranges** | ✗ | ✗ pull | ✓✓ | ✓ | ✓✓ fluent `\|` | ✗ | language |
| **C++ hand-rolled** | ✓ you wrote it | ✓ | ~ manual wiring | ✓ | ✗ | ✗ | nothing |

`✓✓` strongest · `✓` clean · `~` works with friction · `✗` absent.

## Three things the matrix is actually telling you

1. **"Queue, for potential async" is a concurrency-model requirement wearing a data-structure costume.** It silently selects for *a language or library where async dataflow is first-class* (TPL Dataflow, Reactor, SCOOP). Where that's missing — C++ — you reconstruct an actor framework by hand. By your own DSL→GPL algorithm: the queue is "free" in the first three and "resists translation" in C++; that resistance is the datum, not a nuisance.

2. **Reading direction (R3) is decided by API shape — not by push/pull, not by queues.** Fluent builders (Reactor, C++ ranges) read in data-flow order because the builder reverses construction for you. Statement-per-edge wiring (Dataflow, SCOOP, Flow `subscribe`) reads top-down in data-flow order — consistent, just not one expression. Raw observer/`Processor` authoring is the only thing that reads *inside-out* (sink-first). R3 is orthogonal to R1 and R-push.

3. **Only SCOOP places a contract on the queue.** The precondition-as-wait-condition is exactly your thesis's nerve: the synchronization spec *is* the contract. Nobody else expresses readiness/backpressure as DbC. The cost is that the one language that can *state* it is the one whose verifier (AutoProof) refuses the concurrent fragment. Expressible-but-unverifiable is a result, not a dead end.

## The empty intersection (your "no single implementation" instinct, made precise)

You won't find: `{queue + push + composable + typed + single-expression-readable + DbC-verifiable + zero library}`. That set is empty, and the emptiness is the finding.

- Closest to **all functional requirements**: **Reactor** or **TPL Dataflow**. Sacrifice: no contracts, and it's a library.
- Closest to **the spirit of your thesis**: **SCOOP**. Sacrifice: static verification and ecosystem.
- **C++** is the control case that proves requirements 1 and 3 are antagonistic without a blessing library: pick ranges (lose queue+push) or hand-rolled channels (lose readability+composability). You cannot have both in the standard library.
