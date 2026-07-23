note
	description: "[
		Null store: has no keys, lists nothing, accepts nothing.
		The unwired state of a composable stage — `has_key` is
		always False, so the verbs' preconditions can never hold;
		reads that are total (new_cursor, search) answer
		emptiness instead of dying.
		One instance per [K, V] derivation: creation is private,
		access through `instance`.
	]"

frozen class
	RESTLY_NULL [K -> HASHABLE, V]

inherit
	RESTLY_LISTABLE [K, V]

	RESTLY_POSTABLE [K, V]

	RESTLY_PATCHABLE [K, V]

	RESTLY_SEARCHABLE [ANY, K, V]

	ANY
			-- Re-effects default_create/copy/out/is_equal,
			-- which RESTLY_PROTOCOL undefines for its own joins.

create {RESTLY_NULL}
	default_create

feature -- Access

	instance: RESTLY_NULL [K, V]
			-- A null store for [K, V]. Stateless, so identity is
			-- irrelevant; a true once is illegal here (VFFD(7):
			-- once functions may not have a formal-generic result).
		do
			create Result
		ensure
			instance_free: class
		end

feature -- REST verbs

	item alias "[]" (k: K): V assign force
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := item (k)
			end
		end

	has_key (k: K): BOOLEAN
			-- <Precursor>: nothing here.
		do
			Result := False
		end

	extend (v: V; k: K)
			-- <Precursor>
		do
			check this_should_never_be_called: False end
		end

	put (v: V; k: K)
			-- <Precursor>
		do
			check this_should_never_be_called: False end
		end

	remove (k: K)
			-- <Precursor>
		do
			check this_should_never_be_called: False end
		end

feature -- Iteration

	new_cursor: TABLE_ITERATION_CURSOR [V, K]
			-- <Precursor>: an empty stream.
		local
			l_empty: V_HASH_TABLE [K, V]
		do
			create l_empty.with_object_equality
			create {RESTLY_V_MAP_CURSOR [K, V]} Result.make (l_empty.new_cursor)
		end

feature -- Removal

	wipe_out
			-- <Precursor>: nothing to remove.
		do
		end

feature {NONE} -- Key minting

	fresh_key (a_v: V): K
			-- <Precursor>
		do
			check this_should_never_be_called: False then
				Result := fresh_key (a_v)
			end
		end

feature -- Update

	merge (a_patch: V; a_k: K)
			-- <Precursor>
		do
			check this_should_never_be_called: False end
		end

feature -- Search

	search (a_query: ANY): TABLE_ITERATION_CURSOR [V, K]
			-- <Precursor>: nothing matches.
		do
			Result := new_cursor
		end

end
