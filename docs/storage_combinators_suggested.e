note
	description: "Weiher-style storage combinators with lens-based representation conversion."
	caveat: "Sketch. Multiple classes in one file for review; production Eiffel uses one class per file."

-- ===========================================================================

deferred class
	COMBINATOR [K, F, B]
		-- A combinator IS a store: it presents frontend type F upward (via
		-- RESOURCE [K, F]) and consumes backend type B downward.
		--
		-- Chaining `up <- low` type-checks IFF low's frontend type = up's
		-- backend type B. That alignment is a COMPILE-TIME guarantee enforced
		-- by the type system, not a runtime invariant.

inherit
	RESOURCE [K, F]
		redefine
			read	-- illustrative: effect the rest of RESTLY's protocol the same way
		end

feature {NONE} -- initialization

	make (a_medium: RESOURCE [K, F])
			-- This combinator's own near store; the source/chain starts open (Void).
		do
			medium := a_medium
		ensure
			medium_set: medium = a_medium
			open: source = Void
		end

feature -- access

	medium: RESOURCE [K, F]
			-- This combinator's own store (cache buffer, presented store, ...).
			-- NOT the protocol frontend -- the combinator itself is the frontend.

	source: detachable RESOURCE [K, B]
			-- The backend / chain. Void until a `<-` grounds it.
			-- Correctly typed in B: this is where the third generic earns its keep.

	is_grounded: BOOLEAN
			-- Does the chain bottom out in a non-combinator terminal store?
		do
			if attached {COMBINATOR [K, B, detachable ANY]} source as deeper then
				Result := deeper.is_grounded
			else
				Result := source /= Void
			end
		end

feature -- representation conversion (the lens; the reason B is not dead)

	get_view (b: B): F
			-- Read direction: backend representation -> frontend view.
			-- This is RESTLY's `get`.
		deferred
		end

	put_back (f: F; b: B): B
			-- Write direction: new frontend value + old backend -> new backend.
			-- This is RESTLY's `put_back`.
		deferred
		end

feature -- store protocol (illustrative effecting via the lens)

	read (k: K): detachable F
			-- Stand-in for RESTLY's GET. Effect POST/PUT/DELETE identically:
			-- delegate to `source`, convert across the lens.
		do
			if attached source as s and then attached s.read (k) as raw then
				Result := get_view (raw)
			end
		end

feature -- fluent assembly

	backed_by alias "<-" (a_source: RESOURCE [K, B]): like Current
			-- A fresh combinator with `a_source` attached at the DEEPEST OPEN
			-- slot. Functional: builds a twin, never mutates a shared object.
			--
			-- Free operators are left-associative, so
			--     a <- b <- c   ==   (a <- b) <- c
			-- nests CORRECTLY precisely because each `<-` threads to the deepest
			-- open slot instead of overwriting the immediate source.
		do
			Result := Current.twin
			if source = Void then
				Result.set_source (a_source)
			elseif attached {COMBINATOR [K, B, detachable ANY]} source as deeper then
				Result.set_source (deeper <- a_source)
			else
					-- Chain already grounded by a terminal store: re-grounding is a
					-- user error. A precondition is the honest guard (omitted in sketch).
				Result.set_source (a_source)
			end
		ensure
			fresh: Result /= Current
		end

feature {COMBINATOR} -- assembly internals

	set_source (s: RESOURCE [K, B])
			-- Used ONLY during functional assembly, on a freshly twinned object.
			-- Selective export keeps the immutable contract intact externally.
		do
			source := s
		ensure
			source = s
		end

invariant
	medium_attached: medium /= Void
		-- NB: the K/F/B alignment between adjacent combinators is enforced
		-- statically by the type system, so it is intentionally NOT asserted here.

end

-- ===========================================================================

class
	CACHE [K, V]
		-- Pass-through store with an IDENTITY lens (F = B = V); adds caching.

inherit
	COMBINATOR [K, V, V]
		redefine
			read
		end

create
	make

feature -- representation conversion (identity lens)

	get_view (b: V): V
		do
			Result := b
		end

	put_back (f: V; b: V): V
		do
			Result := f
		end

feature -- store protocol

	read (k: K): detachable V
			-- Cache-aside: medium first; a miss delegates to source, then populates.
		do
			Result := medium.read (k)
			if Result = Void then
				Result := Precursor (k)
				if attached Result as r then
					medium.write (k, r)
				end
			end
		end

end

-- ===========================================================================

class
	LOG [K, V]
		-- Pass-through store with an identity lens; records every access.

inherit
	COMBINATOR [K, V, V]
		redefine
			make, read
		end

create
	make

feature {NONE} -- initialization

	make (a_medium: RESOURCE [K, V])
		do
			Precursor (a_medium)
				-- Sink shown created inline; INJECT it in real code.
			create {RESOURCE_HASH [INTEGER, STRING]} sink.make
		end

feature -- representation conversion (identity lens)

	get_view (b: V): V
		do
			Result := b
		end

	put_back (f: V; b: V): V
		do
			Result := f
		end

feature -- store protocol

	read (k: K): detachable V
		do
			append ("read " + k.out)
			Result := Precursor (k)
		end

feature {NONE} -- logging

	sink: RESOURCE [INTEGER, STRING]
			-- The actual log. File or RAM -- the combinator doesn't care.

	tick: INTEGER
			-- Monotonic event counter.

	append (msg: STRING)
		do
			tick := tick + 1
			sink.write (tick, msg)
		end

end

-- ===========================================================================

class
	STORE_COMBINATORS [K, V]
		-- Inherit this to get the assembly vocabulary in scope. Replaces the
		-- ILLEGAL `{CACHE}(x)` type-call syntax (alias "()" dispatches on objects,
		-- not types) with legal factory functions returning fresh, OPEN combinators.

feature -- factories

	cache (a_medium: RESOURCE [K, V]): CACHE [K, V]
		do
			create Result.make (a_medium)
		end

	log (a_medium: RESOURCE [K, V]): LOG [K, V]
		do
			create Result.make (a_medium)
		end

end

-- ===========================================================================

class
	PIPELINE_EXAMPLE [K, V]
		-- Corrected DSL usage. Compare against the broken `{CACHE}(...)` sketch.

inherit
	STORE_COMBINATORS [K, V]

feature -- assembly

	pipeline1 (db, remote: RESOURCE [K, V]): COMBINATOR [K, V, V]
		do
			Result := cache (remote) <- db
		end

	pipeline2 (db, remote_l, remote_h: RESOURCE [K, V]): COMBINATOR [K, V, V]
		do
			Result := log (remote_l) <- cache (remote_h) <- db
		end

	pipeline3 (db, remote_lg, remote_h, local: RESOURCE [K, V]): COMBINATOR [K, V, V]
		do
			Result := cache (local) <- log (remote_lg) <- cache (remote_h) <- db
		end

end
