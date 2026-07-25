note
	description: "[
		Authorization as a store: the world one capability is allowed
		to see (Ideas 2 and 3). Forbidden looks like absent — the
		inherited `error_404_not_found` precondition, dynamically bound
		to the shrunken `has_key`, denies invisible keys with no new
		code. Write denial cannot live in the verbs (they promise
		success by contract); callers pre-check `writable`/`removable`.
		`make_with_back` is narrowed to {RESTLY_COMPOSABLE}: outside
		code's only path to a wired view is `make (a_cap, a_back)`,
		so holding a view proves a valid capability was presented.
	]"

class
	AUTH_VIEW [K -> HASHABLE, V]

inherit
	RESTLY_PROTOCOL [K, V]

	RESTLY_COMPOSABLE [K, V]
		export
			{RESTLY_COMPOSABLE} make_with_back
		end

	ANY
			-- Re-effects default_create/copy/out/is_equal, which
			-- RESTLY_PROTOCOL undefines for its own joins.

create
	make

feature {NONE} -- Initialization

	make (a_cap: CAPABILITY; a_back: RESTLY_PROTOCOL [K, V])
		require
			capability_valid: a_cap.is_valid
		do
			capability := a_cap
			make_with_back (a_back)
		end

feature -- Access

	capability: CAPABILITY
			-- Whose world this is.

feature -- REST verbs

	item alias "[]" (k: K): V assign force
		do
			Result := back.item (k)
		end

	has_key (k: K): BOOLEAN
		do
			Result := back.has_key (k) and capability.readable (k)
		ensure then
			visibility_is_authorization:
				Result = (back.has_key (k) and capability.readable (k))
		end

	extend (v: V; k: K)
		do
			back.extend (v, k)
		end

	put (v: V; k: K)
		do
			back.put (v, k)
		end

	remove (k: K)
		do
			back.remove (k)
		end

feature -- Status report

	writable (k: K): BOOLEAN
			-- May this capability write at `k`? Pre-check for callers:
			-- the write verbs guarantee success by inherited contract.
		do
			Result := capability.writable (k)
		end

	removable (k: K): BOOLEAN
			-- May this capability delete at `k`? Mind the trap: a key
			-- can be read-visible yet not deletable.
		do
			Result := capability.removable (k)
		end

invariant
	capability_valid: capability.is_valid

end
