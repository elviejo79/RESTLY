note
	description: "[
		Minimum set of REST verb abstractions backed by a hash table.
		Strengthens RESTLY_UNSAFE_PROTOCOL with delivery guarantees:
		the mutating verbs promise (ensure then) that the table really
		changed. Stores speak this; fronts that cannot promise delivery
		stay at RESTLY_UNSAFE_PROTOCOL.
		Every store is traversable (EiffelBase2: new_cursor lives on
		V_CONTAINER itself, not a mixin): the container is the
		iterable, `new_cursor` is the only traversal it hands out.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	RESTLY_PROTOCOL [K, V]

inherit
	RESTLY_PATCHABLE [K, V]
		redefine
			force
		end

	TABLE_ITERABLE [V, K]
			-- `new_cursor: TABLE_ITERATION_CURSOR [V, K]` comes from
			-- here: a forward-only stream exposing both keys and values.
		undefine
			is_equal, copy, out, default_create
		end

feature -- REST verbs

	extend (v: V; k: K)
			-- <Precursor>
		deferred
		ensure then
			error_500_didnt_actually_update: has_key(k) and then item(k) ~ v
		end

	force (v: V; k: K)
			-- <Precursor>
		do
			Precursor (v, k)
		ensure then
			error_500_didnt_actually_insert: has_key(k) and then item(k) ~ v
		end

	put (v: V; k: K)
			-- <Precursor>
		deferred
		ensure then
			error_500_didnt_actually_update: item(k) ~ v
		end

	remove (k: K)
			-- <Precursor>
		deferred
		ensure then
			error_500_didnt_actually_delete: not has_key(k)
		end

feature -- Removal

	wipe_out
			-- Remove all entries.
			-- Lives with the mutating verbs, as in EiffelBase2's
			-- V_TABLE — never on a read-only ancestor, never a mixin.
		deferred
		ensure
			empty: new_cursor.after
		end

end
